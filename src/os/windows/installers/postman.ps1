$ErrorActionPreference = "Stop"

$APP_NAME  = "Postman"
$WINGET_ID = "Postman.Postman"
$APP_DIR   = "$env:LOCALAPPDATA\Postman"

# 1. CHECK - Skip if already installed
# Postman (Squirrel-based) installs into a versioned subfolder under
# LOCALAPPDATA\Postman, e.g. app-12.1.4\Postman.exe — no exe at the root.
# Checking for the directory is the reliable detection method.
if (Test-Path $APP_DIR) {
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

# Squirrel installers run asynchronously after winget exits — wait for the
# background process to finish placing files before verifying.
Start-Sleep -Seconds 5

# 4. VERIFY
$exe = Get-ChildItem -Path $APP_DIR -Filter "Postman.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($exe) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
