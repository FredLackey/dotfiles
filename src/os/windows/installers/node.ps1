$ErrorActionPreference = "Stop"

$NodeVersionFile = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\..\.node-version"))

if (-not (Test-Path $NodeVersionFile)) {
    Write-Error "Node version file not found at $NodeVersionFile."
    exit 1
}

$NodeMajorVersion = (Get-Content $NodeVersionFile -Raw).Trim()
$APP_NAME = "Node.js v$NodeMajorVersion"

function Get-InstalledNodeMajorVersion {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        return $null
    }

    $version = (node --version).Trim()
    if ($version -match '^v?([0-9]+)\.') {
        return $Matches[1]
    }

    return $null
}

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 1. CHECK - Skip if already installed
if ((Get-InstalledNodeMajorVersion) -eq $NodeMajorVersion -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME is already installed ($nodeVersion)."
    exit 0
}

# 2. DEPENDENCIES
if (-not (Get-Command msiexec.exe -ErrorAction SilentlyContinue)) {
    Write-Error "msiexec is required to install $APP_NAME."
    exit 1
}

# 3. INSTALL
Write-Host "Installing $APP_NAME..."
$nodeArch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString() -eq "Arm64") { "arm64" } else { "x64" }
$shasumsUrl = "https://nodejs.org/dist/latest-v$NodeMajorVersion.x/SHASUMS256.txt"
$shasums = (Invoke-WebRequest -Uri $shasumsUrl -UseBasicParsing).Content
$installerMatch = [regex]::Match($shasums, "node-v[0-9]+\.[0-9]+\.[0-9]+-$nodeArch\.msi")

if (-not $installerMatch.Success) {
    Write-Error "Unable to resolve a Windows installer for Node.js v$NodeMajorVersion ($nodeArch)."
    exit 1
}

$installerName = $installerMatch.Value
$installerPath = Join-Path $env:TEMP $installerName
Invoke-WebRequest -Uri "https://nodejs.org/dist/latest-v$NodeMajorVersion.x/$installerName" -OutFile $installerPath
Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", "`"$installerPath`"", "/qn", "/norestart") -Wait -NoNewWindow

# Refresh PATH so node/npm are reachable in the current session.
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# 4. VERIFY
if ((Get-InstalledNodeMajorVersion) -eq $NodeMajorVersion -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    $nodeVersion = node --version
    Write-Host "$APP_NAME installed successfully ($nodeVersion)."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
