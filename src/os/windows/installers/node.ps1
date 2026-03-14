$ErrorActionPreference = "Stop"

$APP_NAME = "Node.js (LTS via NVM)"

# 1. CHECK - Skip if already installed
if ((Get-Command node -ErrorAction SilentlyContinue) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME is already installed ($nodeVersion)."
    exit 0
}

# 2. DEPENDENCIES - NVM must be installed first
if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Error "NVM for Windows is required to install $APP_NAME. Run nvm.ps1 first."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
nvm install lts
nvm use lts

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 4. VERIFY
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME installed successfully ($nodeVersion)."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
