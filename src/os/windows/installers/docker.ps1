$ErrorActionPreference = "Stop"

$APP_NAME  = "Docker Desktop"
$WINGET_ID = "Docker.DockerDesktop"
$APP_PATH  = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"

# 1. CHECK - Skip if already installed
if ((Test-Path $APP_PATH) -or (Get-Command docker -ErrorAction SilentlyContinue)) {
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

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 4. VERIFY
if ((Test-Path $APP_PATH) -or (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
