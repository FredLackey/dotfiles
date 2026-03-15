$ErrorActionPreference = "Stop"

$APP_NAME  = "balenaEtcher"
$WINGET_ID = "Balena.Etcher"
$APP_PATH  = "$env:LOCALAPPDATA\balenaEtcher\balenaEtcher.exe"

# 1. CHECK - Skip if already installed (path check, then winget for non-standard install locations)
if (Test-Path $APP_PATH) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}
$wingetList = winget list --id $WINGET_ID --exact --accept-source-agreements 2>&1 | Out-String
if ($wingetList -match [regex]::Escape($WINGET_ID)) {
    Write-Host "$APP_NAME is already installed (verified via winget)."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is required to install $APP_NAME."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
winget install --id $WINGET_ID --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity

# 4. VERIFY - Electron/Squirrel installers run asynchronously after winget exits; retry for up to 60 seconds.
$verified = $false
for ($i = 0; $i -lt 12; $i++) {
    Start-Sleep -Seconds 5
    if (Test-Path $APP_PATH) {
        $verified = $true
        break
    }
}

# Fallback: exe path may vary by installer version; ask winget directly.
if (-not $verified) {
    $wingetCheck = winget list --id $WINGET_ID --exact --accept-source-agreements 2>&1 | Out-String
    if ($wingetCheck -match [regex]::Escape($WINGET_ID)) {
        $verified = $true
        Write-Host "  Note: $APP_NAME installed (verified via winget; exe not at expected path)."
    }
}

if ($verified) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
