$ErrorActionPreference = "Stop"

$APP_NAME = "Starship Config"
$Source   = "$HOME\.dotfiles\src\os\windows\files\starship.toml"
$Target   = "$HOME\.config\starship.toml"

# 1. CHECK - Skip if already up to date
if ((Test-Path $Target) -and
    ((Get-FileHash $Source).Hash -eq (Get-FileHash $Target).Hash)) {
    Write-Host "$APP_NAME is already up to date."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    Write-Error "Starship is required before installing $APP_NAME."
    exit 1
}

if (-not (Test-Path $Source)) {
    Write-Error "Source config not found: $Source"
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
$ConfigDir = Split-Path -Parent $Target
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}
Copy-Item -Path $Source -Destination $Target -Force

# 4. VERIFY
if ((Get-FileHash $Source).Hash -eq (Get-FileHash $Target).Hash) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
