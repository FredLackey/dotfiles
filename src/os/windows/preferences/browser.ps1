$ErrorActionPreference = "Stop"

$PREF_NAME    = "Default Browser"
$CHANGES_MADE = $false

Write-Host "Configuring $PREF_NAME..."

# Helper: set a registry DWORD only if the value differs from what is already there.
function Set-RegDWord {
    param([string]$Path, [string]$Name, [int]$Value)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    $current = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -ne $current -and $current -eq $Value) { return }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type DWord
    $script:CHANGES_MADE = $true
}

# --- Suppress Edge "set me as default" nag prompts (HKCU, no admin needed) ---
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "DefaultBrowserSettingEnabled"                    0
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "ShowRecommendationsEnabled"                      0
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "SpotlightExperiencesAndRecommendationsEnabled"   0
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "PromotionalTabsEnabled"                          0

# --- Disable Edge startup boost (preloads Edge silently at login) ---
# Try HKCU policy first; fall back to HKLM if running as admin.
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled"  0
Set-RegDWord "HKCU:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" 0
try {
    Set-RegDWord "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "StartupBoostEnabled"  0
    Set-RegDWord "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "BackgroundModeEnabled" 0
    Set-RegDWord "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "AllowPrelaunch"        0
} catch {
    Write-Host "  Note: HKLM Edge policies skipped (not running as admin)."
}

# --- Suppress Windows recommendations to use Edge (e.g. after updates) ---
Set-RegDWord "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0

# --- Request Chrome as default browser ---
# On Windows 10 (pre-2024), this sets Chrome silently.
# On Windows 10 v1511+ / Windows 11, Microsoft requires a single manual click
# in Default Apps (Settings will open automatically if needed).
# Enterprise MSI installs to Program Files; user installer uses LOCALAPPDATA. Check both.
$chromeCandidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$chromePath = $chromeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($chromePath) {
    Write-Host "  Requesting Chrome as default browser..."
    Start-Process -FilePath $chromePath -ArgumentList "--make-default-browser" -Wait
    $CHANGES_MADE = $true
    Write-Host "  If a Default Apps window opened, click Chrome to confirm."
} else {
    Write-Host "  Chrome not found - skipping default browser switch."
    Write-Host "  Run google-chrome.ps1 first, then re-run preferences."
}

if ($CHANGES_MADE) {
    Write-Host "$PREF_NAME preferences applied."
} else {
    Write-Host "$PREF_NAME already configured."
}
