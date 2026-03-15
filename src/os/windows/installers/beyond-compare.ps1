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

# 1. CHECK - Skip if already installed (path check, then winget for non-standard install locations)
if (Find-BeyondCompare) {
    Write-Host "$APP_NAME is already installed."
    exit 0
}
$wingetList = winget list --id $WINGET_ID --exact --accept-source-agreements 2>&1 | Out-String
if ($wingetList -match [regex]::Escape($WINGET_ID)) {
    Write-Host "$APP_NAME is already installed (verified via winget)."
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

# 4. VERIFY - NSIS installers can run asynchronously after winget exits; retry for up to 60 seconds.
$verified = $false
for ($i = 0; $i -lt 12; $i++) {
    if (Find-BeyondCompare) {
        $verified = $true
        break
    }
    Start-Sleep -Seconds 5
}

# Fallback: exe path may vary by architecture or install mode; ask winget directly.
if (-not $verified) {
    $wingetCheck = winget list --id $WINGET_ID --exact --accept-source-agreements 2>&1 | Out-String
    if ($wingetCheck -match [regex]::Escape($WINGET_ID)) {
        $verified = $true
        Write-Host "  Note: $APP_NAME installed (verified via winget; exe not at expected paths)."
    }
}

if ($verified) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed."
    exit 1
}
