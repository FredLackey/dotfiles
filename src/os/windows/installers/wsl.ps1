$ErrorActionPreference = "Stop"

$APP_NAME = "WSL2 (Windows Subsystem for Linux)"

# 1. CHECK - Skip if WSL is already installed and functional
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    $wslStatus = wsl --status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$APP_NAME is already installed."
        exit 0
    }
}

# 2. DEPENDENCIES - Requires admin (to enable Windows optional features)
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "$APP_NAME installation requires admin rights."
    exit 1
}

# 3. INSTALL
# --no-distribution installs WSL2 and the kernel without immediately launching
# Ubuntu's interactive user-creation prompt. Run the ubuntu-wsl dotfiles setup
# after restarting to install and configure a Linux distribution.
Write-Host "Installing $APP_NAME..."
wsl --install --no-distribution

# 4. VERIFY
# wsl --install returns 0 on success. A restart is always required before WSL
# is fully operational — note this but do not exit with an error.
if ($LASTEXITCODE -eq 0) {
    Write-Host "$APP_NAME installed successfully."
    Write-Host "IMPORTANT: A restart is required before WSL2 is operational."
    Write-Host "After restarting, install Ubuntu with: wsl --install --distribution Ubuntu"
} else {
    Write-Error "$APP_NAME installation failed (exit code $LASTEXITCODE)."
    exit 1
}
