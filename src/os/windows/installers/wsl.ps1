$ErrorActionPreference = "Stop"

$APP_NAME = "WSL2 (Windows Subsystem for Linux)"

# Detect current state
$wslInstalled   = (Get-Command wsl -ErrorAction SilentlyContinue) -and ((wsl --status 2>&1 | Out-String) -match "Default Version")
$ubuntuInstalled = $wslInstalled -and ((wsl --list --quiet 2>&1 | Out-String) -match "Ubuntu")

# --- FULLY DONE: both WSL2 and Ubuntu are present ---
if ($wslInstalled -and $ubuntuInstalled) {
    Write-Host "$APP_NAME and Ubuntu are already installed."
    exit 0
}

# Require admin for both stages
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "$APP_NAME installation requires admin rights."
    exit 1
}

# --- STAGE 1: WSL2 not yet installed ---
# Install WSL2 and the kernel only. No distribution yet — avoids the
# interactive Ubuntu user-creation prompt during the initial setup run.
# After this completes, reboot and re-run setup to proceed to Stage 2.
if (-not $wslInstalled) {
    Write-Host "Installing $APP_NAME (Stage 1 of 2)..."
    wsl --install --no-distribution
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$APP_NAME installation failed (exit code $LASTEXITCODE)."
        exit 1
    }
    Write-Host ""
    Write-Host "$APP_NAME installed successfully."
    Write-Host "ACTION REQUIRED: Restart the machine, then re-run setup to install Ubuntu (Stage 2)."
    exit 0
}

# --- STAGE 2: WSL2 is installed but Ubuntu is not yet present ---
# Download and register the Ubuntu distribution. The first time Ubuntu is
# launched interactively the user will be prompted to create a Linux user —
# that happens outside of this script.
Write-Host "Installing Ubuntu on WSL2 (Stage 2 of 2)..."
wsl --install --distribution Ubuntu
if ($LASTEXITCODE -ne 0) {
    Write-Error "Ubuntu installation failed (exit code $LASTEXITCODE)."
    exit 1
}
Write-Host "Ubuntu installed successfully."
Write-Host "Launch Ubuntu from the Start Menu to complete initial user setup,"
Write-Host "then run the ubuntu-wsl dotfiles setup inside it."
