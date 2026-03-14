$ErrorActionPreference = "Stop"

$APP_NAME  = "Google Chrome"
$WINGET_ID = "Google.Chrome"
$APP_PATH  = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$APP_PATH2 = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"

# 1. CHECK - Skip if already installed
if ((Test-Path $APP_PATH) -or (Test-Path $APP_PATH2)) {
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
if ((Test-Path $APP_PATH) -or (Test-Path $APP_PATH2)) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
