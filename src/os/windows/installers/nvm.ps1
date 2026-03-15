$ErrorActionPreference = "Stop"

$APP_NAME  = "NVM for Windows"
$WINGET_ID = "CoreyButler.NVMforWindows"

# Helper: reload NVM env vars and PATH from registry into the current session
function Refresh-NvmEnv {
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
}

# 1. CHECK - Skip if already installed
Refresh-NvmEnv
if ($env:NVM_HOME -and (Test-Path $env:NVM_HOME)) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}
if (Get-Command nvm -ErrorAction SilentlyContinue) {
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
winget install --id $WINGET_ID --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity

# Reload env vars set by the NVM installer (NVM_HOME, NVM_SYMLINK, PATH)
Refresh-NvmEnv

# 4. VERIFY
if (($env:NVM_HOME -and (Test-Path $env:NVM_HOME)) -or (Get-Command nvm -ErrorAction SilentlyContinue)) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
