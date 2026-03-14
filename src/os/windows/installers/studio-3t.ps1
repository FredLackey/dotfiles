$ErrorActionPreference = "Stop"

$APP_NAME  = "Studio 3T"
$WINGET_ID = "3TSoftwareLabs.Studio3T"
$APP_PATH  = "$env:ProgramFiles\3T Software Labs\Studio 3T\Studio 3T.exe"

# 1. CHECK - Skip if already installed
if (Test-Path $APP_PATH) {
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
