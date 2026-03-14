$ErrorActionPreference = "Stop"

$APP_NAME  = "Beyond Compare"
$WINGET_ID = "ScooterSoftware.BeyondCompare.5"

# Beyond Compare's NSIS installer places BCompare.exe in different locations
# depending on architecture - check all known paths.
$APP_PATHS = @(
    "$env:ProgramFiles\Beyond Compare 5\BCompare.exe",
    "${env:ProgramFiles(x86)}\Beyond Compare 5\BCompare.exe"
)

function Find-BeyondCompare {
    foreach ($p in $APP_PATHS) {
        if (Test-Path $p) { return $p }
    }
    if (Get-Command BCompare -ErrorAction SilentlyContinue) { return "BCompare" }
    return $null
}

# 1. CHECK - Skip if already installed
if (Find-BeyondCompare) {
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

# 4. VERIFY - NSIS installers can run asynchronously after winget exits; retry for up to 60 seconds.
$verified = $false
for ($i = 0; $i -lt 12; $i++) {
    if (Find-BeyondCompare) {
        $verified = $true
        break
    }
    Start-Sleep -Seconds 5
}

if ($verified) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
