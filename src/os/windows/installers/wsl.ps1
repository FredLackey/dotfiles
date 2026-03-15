$ErrorActionPreference = "Stop"

$APP_NAME = "WSL2 (Windows Subsystem for Linux)"

# Detect WSL state safely - wsl --status throws on machines where the
# feature has never been enabled, so wrap it in a try/catch.
$wslInstalled    = $false
$ubuntuInstalled = $false

try {
    $wslStatus = wsl --status 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -or $wslStatus -match "Default Version") {
        $wslInstalled = $true
    }
} catch {
    $wslInstalled = $false
}

if ($wslInstalled) {
    try {
        $distros = wsl --list --quiet 2>&1 | Out-String
        $ubuntuInstalled = $distros -match "Ubuntu"
    } catch {
        $ubuntuInstalled = $false
    }
}

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

# --- STAGE 2: WSL2 installed, Ubuntu not yet present ---
Write-Host "Installing Ubuntu on WSL2 (Stage 2 of 2)..."
wsl --install --distribution Ubuntu --no-launch
if ($LASTEXITCODE -ne 0) {
    Write-Error "Ubuntu installation failed (exit code $LASTEXITCODE)."
    exit 1
}

# Provision the default user non-interactively using the current Windows username.
# Running as root avoids the interactive "Create a default Unix user account" prompt.
$linuxUser = $env:USERNAME.ToLower()
Write-Host "  Provisioning Linux user '$linuxUser'..."

wsl --distribution Ubuntu --user root -- useradd -m -s /bin/bash $linuxUser
wsl --distribution Ubuntu --user root -- usermod -aG sudo $linuxUser
# Passwordless sudo — standard for a dev machine; the user can tighten this later.
wsl --distribution Ubuntu --user root -- bash -c "echo '${linuxUser} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${linuxUser} && chmod 0440 /etc/sudoers.d/${linuxUser}"

# Set the default user so future `wsl` invocations drop straight into the user shell.
$ubuntuExe = "$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu.exe"
if (Test-Path $ubuntuExe) {
    & $ubuntuExe config --default-user $linuxUser
} else {
    wsl --distribution Ubuntu --user root -- bash -c "printf '[user]\ndefault=$linuxUser\n' > /etc/wsl.conf"
}

Write-Host "Ubuntu installed successfully."
Write-Host "  User '$linuxUser' created with passwordless sudo."
Write-Host "  Run the ubuntu-wsl dotfiles setup inside Ubuntu when ready."
