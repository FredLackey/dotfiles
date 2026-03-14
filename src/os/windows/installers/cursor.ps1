$ErrorActionPreference = "Stop"

$APP_NAME   = "Cursor"
$WINGET_ID  = "Anysphere.Cursor"
$APP_PATH   = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"

# 1. CHECK - Skip if already installed
if ((Test-Path $APP_PATH) -or (Get-Command cursor -ErrorAction SilentlyContinue)) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is required to install $APP_NAME."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
winget install --id $WINGET_ID --exact --silent --accept-package-agreements --accept-source-agreements

# 4. VERIFY
if (Test-Path $APP_PATH) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
