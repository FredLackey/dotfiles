$ErrorActionPreference = "Stop"

$APP_NAME  = "Slack"
$WINGET_ID = "SlackTechnologies.Slack"
$APP_DIR   = "$env:LOCALAPPDATA\slack"

# 1. CHECK - Skip if already installed
# Slack (Squirrel-based) installs into a versioned subfolder under LOCALAPPDATA\slack,
# e.g. app-4.48.0\slack.exe - there is no slack.exe at the root level.
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

# 4. VERIFY - Squirrel installers run asynchronously after winget exits; retry for up to 60 seconds.
$verified = $false
for ($i = 0; $i -lt 12; $i++) {
    Start-Sleep -Seconds 5
    $slack_exe = Get-ChildItem -Path $APP_DIR -Filter "slack.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($slack_exe) {
        $verified = $true
        break
    }
}

# Fallback: install dir or exe path may vary; ask winget directly.
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
