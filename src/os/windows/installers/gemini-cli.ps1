$ErrorActionPreference = "Stop"

$APP_NAME = "Gemini CLI"

# 1. CHECK - Skip if already installed
if (Get-Command gemini -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm is required to install $APP_NAME."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
npm install -g @google/gemini-cli

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 4. VERIFY
if (Get-Command gemini -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
