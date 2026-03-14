$ErrorActionPreference = "Stop"

$APP_NAME  = "Claude Code"
$WINGET_ID = "Anthropic.ClaudeCode"

# 1. CHECK - Skip if already installed
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is required to install $APP_NAME."
    exit 1
}

# 3. INSTALL
# npm installation is deprecated per Anthropic docs. Use winget (official, auto-updates).
# Native installer alternative: iex (iwr -useb 'https://claude.ai/install.ps1').Content
Write-Host "Installing $APP_NAME..."
winget install --id $WINGET_ID --exact --silent --accept-package-agreements --accept-source-agreements

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 4. VERIFY
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
