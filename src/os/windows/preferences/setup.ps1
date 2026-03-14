$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=================================================="
Write-Host "Configuring Windows system preferences..."
Write-Host "=================================================="

# Check if a category is excluded via DOTFILES_EXCLUDE environment variable
function Is-Excluded {
    param([string]$Category)
    $exclude = $env:DOTFILES_EXCLUDE
    if (-not $exclude) { return $false }
    $excludeUpper  = $exclude.ToUpper()
    $categoryUpper = $Category.ToUpper()
    return ",$excludeUpper," -like "*,$categoryUpper,*"
}

# Run a preference script. Failures are caught and reported; they do not abort setup.
function Run-Preference {
    param(
        [string]$ScriptName,
        [string]$Category = ""
    )

    if ($Category -and (Is-Excluded $Category)) {
        Write-Host "--------------------------------------------------"
        Write-Host "Skipping preference (excluded category $Category): $ScriptName"
        return
    }

    $ScriptPath = "$ScriptDir\$ScriptName"
    if (-not (Test-Path $ScriptPath)) {
        Write-Host "WARNING: Preference script not found: $ScriptName"
        return
    }

    Write-Host "--------------------------------------------------"
    try {
        & $ScriptPath
    } catch {
        Write-Host "WARNING: $ScriptName failed: $_"
    }
}

# Categories: SYSTEM, DESKTOP, APPS

Run-Preference "browser.ps1"  "APPS"
Run-Preference "taskbar.ps1"  "DESKTOP"
Run-Preference "keyboard.ps1" "SYSTEM"
Run-Preference "onedrive.ps1" "SYSTEM"

Write-Host "--------------------------------------------------"
Write-Host "Windows system preferences configuration complete."
