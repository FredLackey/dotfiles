$ErrorActionPreference = "Stop"

$APP_NAME  = "Slack"
$WINGET_ID = "SlackTechnologies.Slack"
$APP_DIR   = "$env:LOCALAPPDATA\slack"

# 1. CHECK - Skip if already installed
# Slack (Squirrel-based) installs into a versioned subfolder under LOCALAPPDATA\slack,
# e.g. LOCALAPPDATA\slack\app-4.48.0\slack.exe — there is no slack.exe at the root level.
# Checking for the directory is the reliable way to detect an existing installation.
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

# 4. VERIFY
$slack_exe = Get-ChildItem -Path $APP_DIR -Filter "slack.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($slack_exe) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
