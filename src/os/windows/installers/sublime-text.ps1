$ErrorActionPreference = "Stop"

$APP_NAME  = "Sublime Text"
$WINGET_ID = "SublimeHQ.SublimeText.4"
$APP_PATH  = "$env:ProgramFiles\Sublime Text\sublime_text.exe"

# 1. CHECK - Skip if already installed
if ((Test-Path $APP_PATH) -or (Get-Command subl -ErrorAction SilentlyContinue)) {
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
winget install --id $WINGET_ID --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity

# 4. VERIFY
if (Test-Path $APP_PATH) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
