$ErrorActionPreference = "Stop"

$APP_NAME   = "Shell Config"
$FilesDir   = "$HOME\.dotfiles\src\os\windows\files"
$ProfileSrc = "$FilesDir\profile.ps1"

# PowerShell 7 uses $PROFILE.CurrentUserAllHosts by default;
# fall back to the standard CurrentUserCurrentHost profile path.
$ProfileTarget = $PROFILE

# 1. CHECK - Skip if already up to date
if ((Test-Path $ProfileTarget) -and
    ((Get-FileHash $ProfileSrc).Hash -eq (Get-FileHash $ProfileTarget).Hash)) {
    Write-Host "$APP_NAME is already up to date."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Test-Path $ProfileSrc)) {
    Write-Error "Source file not found: $ProfileSrc"
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."

# Set execution policy to RemoteSigned for the current user so local scripts
# (including the PowerShell profile) can run without elevation.
# RemoteSigned = local scripts run freely; downloaded scripts must be signed.
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -notin @("RemoteSigned", "Unrestricted", "Bypass")) {
    Write-Host "  Setting execution policy to RemoteSigned for CurrentUser..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

$ProfileDir = Split-Path -Parent $ProfileTarget
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}
Copy-Item -Path $ProfileSrc -Destination $ProfileTarget -Force
Write-Host "  Deployed profile.ps1 to $ProfileTarget"

# 4. VERIFY
if ((Get-FileHash $ProfileSrc).Hash -eq (Get-FileHash $ProfileTarget).Hash) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
