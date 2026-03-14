$ErrorActionPreference = "Stop"

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
    Write-Host "Files already present in $TargetDir (no git repo). Skipping download."

} else {
    Write-Host "Downloading dotfiles..."

    $TempZip    = "$env:TEMP\dotfiles.zip"
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
$ScriptToRun = "$ScriptDir\os\windows\setup.ps1"
if (Test-Path $ScriptToRun) {
    & $ScriptToRun
} else {
    Write-Error "Could not find setup script: $ScriptToRun"
    exit 1
}
