$ErrorActionPreference = "Stop"

# Set execution policy immediately so local scripts (including PowerShell
# profiles surfaced via Parallels' C:\Mac\Home share) load without errors
# in any new shell opened during or after setup.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Create a timestamped log file on the Desktop. Start-Transcript does not
# work inside iex (no script host context), so we write the header manually
# and let the child process (run via -File) own the real transcript.
$env:DOTFILES_LOG = "$env:USERPROFILE\Desktop\dotfiles-setup-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
"=== dotfiles setup started $(Get-Date) ===" | Set-Content -Path $env:DOTFILES_LOG -Encoding UTF8
Write-Host "Logging to: $env:DOTFILES_LOG"

try {

$ZipUrl    = "https://github.com/FredLackey/dotfiles/archive/refs/heads/main.zip"
$RepoUrl   = "https://github.com/FredLackey/dotfiles.git"
$TargetDir = "$HOME\.dotfiles"

# 1. Download & Extract (Idempotent)
if ((Test-Path $TargetDir) -and (Test-Path "$TargetDir\.git")) {
    Write-Host "Dotfiles already installed. Pulling latest updates..."

    # Ensure remote origin exists and points to the correct URL
    $currentRemote = & git -C $TargetDir remote get-url origin 2>$null
    if (-not $currentRemote) {
        git -C $TargetDir remote add origin $RepoUrl
    } elseif ($currentRemote.Trim() -ne $RepoUrl) {
        git -C $TargetDir remote set-url origin $RepoUrl
    }

    # Ensure local branch is main and tracks origin/main
    $localBranch = & git -C $TargetDir branch --show-current 2>$null
    if ($localBranch -and $localBranch.Trim() -ne "main") {
        git -C $TargetDir branch -m $localBranch.Trim() main
    }
    git -C $TargetDir fetch origin main
    git -C $TargetDir branch --set-upstream-to=origin/main main 2>$null

    try {
        git -C $TargetDir pull --ff-only origin main
    } catch {
        Write-Host "Warning: git pull failed. Continuing with existing files."
    }

} elseif (Test-Path $TargetDir) {
    # Folder exists but has no .git — initialize a repo and wire up the remote
    # so this and all future runs can use git pull instead of re-downloading.
    Write-Host "Dotfiles folder exists without git repo. Initializing git and setting remote..."
    git -C $TargetDir init
    git -C $TargetDir remote add origin $RepoUrl
    git -C $TargetDir fetch origin main
    git -C $TargetDir branch -m main 2>$null
    git -C $TargetDir branch --set-upstream-to=origin/main main
    git -C $TargetDir reset --hard origin/main
    Write-Host "Dotfiles git repo initialized at $TargetDir"

} else {
    Write-Host "Downloading dotfiles (git not available, using zip)..."

    $TempZip     = "$env:TEMP\dotfiles.zip"
    $TempExtract = "$env:TEMP\dotfiles-extract"

    Invoke-WebRequest -Uri $ZipUrl -OutFile $TempZip -UseBasicParsing

    if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }
    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    # GitHub zip contains a single top-level folder (e.g. "dotfiles-main")
    $extracted = Get-ChildItem $TempExtract | Select-Object -First 1
    Move-Item -Path $extracted.FullName -Destination $TargetDir

    Remove-Item $TempZip -Force
    Remove-Item $TempExtract -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Dotfiles downloaded to $TargetDir"
}

# 2. Determine script directory
# Use local path if invoked from a cloned repo; otherwise fall back to downloaded copy
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir -or -not (Test-Path "$ScriptDir\os\windows\setup.ps1")) {
    $ScriptDir = "$TargetDir\src"
}

# 3. Run Windows setup
# Spawn a new PowerShell process with -ExecutionPolicy Bypass so all child
# scripts can be loaded from disk without hitting the default Restricted policy.
# $env:DOTFILES_EXCLUDE is an environment variable and is inherited automatically.
    $ScriptToRun = "$ScriptDir\os\windows\setup.ps1"
    if (Test-Path $ScriptToRun) {
        powershell.exe -ExecutionPolicy Bypass -File $ScriptToRun
        $exitCode = $LASTEXITCODE
    } else {
        Write-Host "ERROR: Could not find setup script: $ScriptToRun"
        $exitCode = 1
    }

} catch {
    Write-Host ""
    Write-Host "ERROR: Setup failed with an unexpected error:"
    Write-Host "  $($_.Exception.Message)"
    Write-Host "  At: $($_.InvocationInfo.PositionMessage)"
    $exitCode = 1
} finally {
    Write-Host ""
    Write-Host "Log saved to: $env:DOTFILES_LOG"
    Write-Host ""
    Read-Host "Press Enter to close this window"
}

exit $exitCode
