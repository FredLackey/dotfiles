$ErrorActionPreference = "Stop"

$APP_NAME  = "Termius"
$APP_PATH  = "$env:LOCALAPPDATA\Programs\Termius\Termius.exe"

# 1. CHECK - Skip if already installed
if (Test-Path $APP_PATH) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES - None; direct download requires only PowerShell built-ins

# 3. INSTALL
# winget uses Termius's rolling autoupdate URL; the manifest hash goes stale
# on each release and cannot be bypassed when running as admin. Download
# directly from the same official URL winget would use.
Write-Host "Installing $APP_NAME..."

$installerUrl  = "https://autoupdate.termius.com/windows/Install%20Termius.exe"
$installerPath = "$env:TEMP\termius_installer.exe"
Write-Host "  Downloading from $installerUrl..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

Write-Host "  Running installer..."
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

# 4. VERIFY
if (Test-Path $APP_PATH) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
