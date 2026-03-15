$ErrorActionPreference = "Stop"

$PREF_NAME    = "Console Font"
$CHANGES_MADE = $false
$FONT_NAME    = "MesloLGS NF"

Write-Host "Configuring $PREF_NAME..."

# --- Register font with the Windows console ---
# The console font picker only lists fonts registered under HKCU:\Console\TrueTypeFont.
# Entries are named "0", "00", "000", etc. — add one for MesloLGS NF if not present.
$ttfKey = "HKCU:\Console\TrueTypeFont"
if (-not (Test-Path $ttfKey)) {
    New-Item -Path $ttfKey -Force | Out-Null
}
$ttfProps   = Get-ItemProperty -Path $ttfKey -ErrorAction SilentlyContinue
$ttfValues  = $ttfProps.PSObject.Properties | Where-Object { $_.Name -match '^0+$' } | Select-Object -ExpandProperty Value
if ($ttfValues -notcontains $FONT_NAME) {
    $existingKeys = $ttfProps.PSObject.Properties | Where-Object { $_.Name -match '^0+$' } | Select-Object -ExpandProperty Name
    $nextKey = "0" * ($existingKeys.Count + 1)
    Set-ItemProperty -Path $ttfKey -Name $nextKey -Value $FONT_NAME -Type String
    $CHANGES_MADE = $true
    Write-Host "  Registered $FONT_NAME with Windows console font picker."
} else {
    Write-Host "  $FONT_NAME already registered with console font picker."
}

# --- Legacy console host (conhost.exe) ---
# Font settings for powershell.exe are stored under a key named after the exe path
# with backslashes replaced by underscores.
$consolePath = "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"
if (-not (Test-Path $consolePath)) {
    New-Item -Path $consolePath -Force | Out-Null
}
$currentFace = (Get-ItemProperty -Path $consolePath -Name "FaceName" -ErrorAction SilentlyContinue).FaceName
if ($currentFace -ne $FONT_NAME) {
    Set-ItemProperty -Path $consolePath -Name "FaceName"   -Value $FONT_NAME -Type String
    Set-ItemProperty -Path $consolePath -Name "FontFamily" -Value 54         -Type DWord  # TrueType monospace
    Set-ItemProperty -Path $consolePath -Name "FontWeight" -Value 400        -Type DWord  # Normal weight
    $CHANGES_MADE = $true
    Write-Host "  Set PowerShell console font to $FONT_NAME."
} else {
    Write-Host "  PowerShell console font already set to $FONT_NAME."
}

# --- Windows Terminal ---
# WT stores per-profile and default font settings in settings.json.
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    try {
        $json    = Get-Content $wtSettings -Raw | ConvertFrom-Json
        $changed = $false

        # Ensure profiles.defaults exists
        if (-not $json.profiles) {
            $json | Add-Member -NotePropertyName "profiles" -NotePropertyValue ([PSCustomObject]@{ defaults = [PSCustomObject]@{} }) -Force
        }
        if (-not $json.profiles.defaults) {
            $json.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue ([PSCustomObject]@{}) -Force
        }

        # Set font face in the defaults block
        if (-not $json.profiles.defaults.font) {
            $json.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue ([PSCustomObject]@{ face = $FONT_NAME }) -Force
            $changed = $true
        } elseif ($json.profiles.defaults.font.face -ne $FONT_NAME) {
            $json.profiles.defaults.font.face = $FONT_NAME
            $changed = $true
        }

        if ($changed) {
            $json | ConvertTo-Json -Depth 20 | Set-Content $wtSettings -Encoding UTF8
            $CHANGES_MADE = $true
            Write-Host "  Set Windows Terminal default font to $FONT_NAME."
        } else {
            Write-Host "  Windows Terminal font already set to $FONT_NAME."
        }
    } catch {
        Write-Host "  Note: Could not update Windows Terminal settings: $_"
    }
} else {
    Write-Host "  Windows Terminal not installed, skipping."
}

if ($CHANGES_MADE) {
    Write-Host "$PREF_NAME configured. Open a new terminal window to see the changes."
} else {
    Write-Host "$PREF_NAME already configured."
}
