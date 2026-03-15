$ErrorActionPreference = "Stop"

$PREF_NAME    = "Taskbar"
$CHANGES_MADE = $false

Write-Host "Configuring $PREF_NAME..."

$AdvancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

# Helper: set a registry DWORD only if the value differs.
# Skips gracefully on access denied — no ACL modification attempted.
function Set-RegDWord {
    param([string]$Path, [string]$Name, [int]$Value)
    if (-not (Test-Path $Path)) {
        try { New-Item -Path $Path -Force | Out-Null } catch { return }
    }
    $current = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -ne $current -and $current -eq $Value) { return }
    try {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord
        $script:CHANGES_MADE = $true
    } catch {
        Write-Host "  Note: Could not set $Name at $Path (access denied, skipping)."
    }
}

# --- Hide Copilot button (Windows 11) ---
Set-RegDWord $AdvancedPath "ShowCopilotButton" 0
# Policy-level disable (more persistent across updates)
Set-RegDWord "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1

# --- Hide Widgets button ---
Set-RegDWord $AdvancedPath "TaskbarDa" 0
Set-RegDWord "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2

# --- Hide Task View button ---
Set-RegDWord $AdvancedPath "ShowTaskViewButton" 0

# --- Unpin Microsoft Edge from taskbar ---
$taskbarPinsDir = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$edgeLnk        = "$taskbarPinsDir\Microsoft Edge.lnk"
if (Test-Path $edgeLnk) {
    Remove-Item $edgeLnk -Force
    $CHANGES_MADE = $true
    Write-Host "  Removed Edge taskbar pin shortcut."
}
try {
    $edgeExe = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgeExe)) { $edgeExe = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe" }
    if (Test-Path $edgeExe) {
        $shell = New-Object -ComObject Shell.Application
        $dir   = $shell.Namespace([System.IO.Path]::GetDirectoryName($edgeExe))
        $item  = $dir.ParseName([System.IO.Path]::GetFileName($edgeExe))
        $unpin = $item.Verbs() | Where-Object { $_.Name -match "unpin" }
        if ($unpin) {
            $unpin | ForEach-Object { $_.DoIt() }
            $CHANGES_MADE = $true
            Write-Host "  Unpinned Microsoft Edge from taskbar (COM)."
        }
    }
} catch {
    # COM unpin not available; .lnk removal above is sufficient.
}

# Prevent Edge from auto-repinning itself after updates.
$edgeSetupKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}"
try {
    if (Test-Path $edgeSetupKey) {
        $stub = (Get-ItemProperty -Path $edgeSetupKey -Name "StubPath" -ErrorAction SilentlyContinue).StubPath
        if ($stub) {
            Remove-ItemProperty -Path $edgeSetupKey -Name "StubPath" -Force
            $CHANGES_MADE = $true
            Write-Host "  Cleared Edge Active Setup auto-pin stub."
        }
    }
} catch {
    Write-Host "  Note: Could not clear Edge Active Setup stub (may need admin)."
}

# --- Restart Explorer to apply taskbar changes ---
if ($CHANGES_MADE) {
    Write-Host "  Restarting Explorer to apply taskbar changes..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Host "$PREF_NAME preferences applied."
    Write-Host "  Note: Copilot and Widgets button changes require a full system restart to take effect."
} else {
    Write-Host "$PREF_NAME already configured."
}
