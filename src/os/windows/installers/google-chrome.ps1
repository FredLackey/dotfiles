$ErrorActionPreference = "Stop"

$APP_NAME  = "Google Chrome"
$APP_PATH  = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$APP_PATH2 = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"

# 1. CHECK - Skip if already installed
if ((Test-Path $APP_PATH) -or (Test-Path $APP_PATH2)) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}

# 2. DEPENDENCIES - None; direct download requires only PowerShell built-ins

# 3. INSTALL
# winget uses a rolling URL for Chrome; the hash in its manifest becomes stale
# as soon as a new version ships, causing hash mismatch failures when running
# as admin (where --ignore-security-hash is blocked). Download directly instead.
Write-Host "Installing $APP_NAME..."

# Detect CPU architecture and pick the matching MSI
$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
if ($arch -like "*ARM*") {
    $installerUrl = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise_arm64.msi"
} elseif ([System.Environment]::Is64BitOperatingSystem) {
    $installerUrl = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi"
} else {
    $installerUrl = "https://dl.google.com/chrome/install/googlechromestandaloneenterprise.msi"
}

$installerPath = "$env:TEMP\chrome_installer.msi"
Write-Host "  Downloading from $installerUrl..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing

Write-Host "  Running installer..."
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

# 4. VERIFY
if ((Test-Path $APP_PATH) -or (Test-Path $APP_PATH2)) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
