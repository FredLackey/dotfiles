$ErrorActionPreference = "Stop"

$APP_NAME = "Node.js (LTS via NVM)"

# Reload NVM env vars and PATH from registry so nvm is reachable even if
# it was just installed in the same session by nvm.ps1.
$env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "User")
if (-not $env:NVM_HOME) {
    $env:NVM_HOME = [System.Environment]::GetEnvironmentVariable("NVM_HOME", "Machine")
}
$env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "User")
if (-not $env:NVM_SYMLINK) {
    $env:NVM_SYMLINK = [System.Environment]::GetEnvironmentVariable("NVM_SYMLINK", "Machine")
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 1. CHECK - Skip if already installed
if ((Get-Command node -ErrorAction SilentlyContinue) -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME is already installed ($nodeVersion)."
    exit 0
}

# 2. DEPENDENCIES - NVM must be installed and reachable
$nvmExe = $null
if (Get-Command nvm -ErrorAction SilentlyContinue) {
    $nvmExe = "nvm"
} elseif ($env:NVM_HOME -and (Test-Path "$env:NVM_HOME\nvm.exe")) {
    $nvmExe = "$env:NVM_HOME\nvm.exe"
}

if (-not $nvmExe) {
    Write-Error "NVM for Windows is required to install $APP_NAME. Run nvm.ps1 first."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
& $nvmExe install lts
& $nvmExe use lts

# Refresh PATH so node/npm from the NVM symlink are reachable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($env:NVM_SYMLINK -and ($env:Path -notlike "*$env:NVM_SYMLINK*")) {
    $env:Path = "$env:NVM_SYMLINK;$env:Path"
}

# 4. VERIFY
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME installed successfully ($nodeVersion)."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
