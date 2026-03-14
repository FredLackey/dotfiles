$ErrorActionPreference = "Stop"

$APP_NAME = "Bun"

# 1. CHECK - Skip if already installed
if (Get-Command bun -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES - None required; installer script is self-contained

# 3. INSTALL - Use the official Bun PowerShell installer (https://bun.sh/docs/installation)
Write-Host "Installing $APP_NAME..."
powershell -c "irm bun.sh/install.ps1 | iex"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# 4. VERIFY
if (Get-Command bun -ErrorAction SilentlyContinue) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
