$ErrorActionPreference = "Stop"

$APP_NAME  = "draw.io"
$WINGET_ID = "JGraph.Draw"

# draw.io's NSIS installer places the exe in different locations depending on
# architecture and whether it runs elevated. Check all known paths.
$APP_PATHS = @(
    "$env:ProgramFiles\draw.io\draw.io.exe",
    "${env:ProgramFiles(x86)}\draw.io\draw.io.exe",
    "$env:LOCALAPPDATA\Programs\draw.io\draw.io.exe"
)

function Find-DrawIo {
    foreach ($p in $APP_PATHS) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

# 1. CHECK - Skip if already installed
if (Find-DrawIo) {
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

# 4. VERIFY - NSIS installers run asynchronously after winget exits; retry for up to 60 seconds.
$verified = $false
for ($i = 0; $i -lt 12; $i++) {
    if (Find-DrawIo) {
        $verified = $true
        break
    }
    Start-Sleep -Seconds 5
}

if ($verified) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed - executable not found in any expected location."
    exit 1
}
