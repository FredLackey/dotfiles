$ErrorActionPreference = "Stop"

$APP_NAME = "Nerd Fonts"

# Determine whether this process is elevated (running as admin).
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

# System fonts (C:\Windows\Fonts) are visible to ALL processes including elevated ones.
# Per-user fonts (%LOCALAPPDATA%\Microsoft\Windows\Fonts) are only visible to non-elevated
# processes — elevated PowerShell won't see them.  Install system-wide when admin, user-only
# as fallback so the script stays idempotent even when run without elevation.
if ($isAdmin) {
    $FontsDir  = "$env:SystemRoot\Fonts"
    $RegPath   = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $RegValue  = "filename"   # system fonts register with filename only (no path)
    $FontScope = "system"
} else {
    $FontsDir  = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $RegPath   = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $RegValue  = "fullpath"   # user fonts register with full path
    $FontScope = "user"
}

$MarkerFile = "$FontsDir\MesloLGS-NF-Regular.ttf"

# 1. CHECK - Skip if already installed (marker is the MesloLGS NF Regular file)
if (Test-Path $MarkerFile) {
    Write-Host "$APP_NAME are already installed ($FontScope)."
    exit 0
}

# 2. DEPENDENCIES - PowerShell and Invoke-WebRequest are built-in; no extra deps needed

# 3. INSTALL
Write-Host "Installing $APP_NAME ($FontScope)..."

if (-not (Test-Path $FontsDir)) {
    New-Item -ItemType Directory -Path $FontsDir -Force | Out-Null
}

$TempDir = "$env:TEMP\nerd-fonts-install"
if (-not (Test-Path $TempDir)) { New-Item -ItemType Directory -Path $TempDir -Force | Out-Null }

# --- MesloLGS NF (romkatv's Powerlevel10k variant, single TTF) ---
# This is the MesloLGS NF build patched specifically for Powerlevel10k.
# The canonical nerd-fonts repo calls this variant "Meslo LG S"; the romkatv
# build is preferred here because it is the one p10k recommends explicitly.
$mesloSrc  = "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
$mesloDest = "$FontsDir\MesloLGS-NF-Regular.ttf"
Write-Host "  Downloading MesloLGS NF Regular..."
Invoke-WebRequest -Uri $mesloSrc -OutFile $mesloDest -UseBasicParsing

# --- JetBrainsMono Nerd Font and FiraCode Nerd Font (official zip releases) ---
$zipFonts = @(
    @{ Name = "JetBrainsMono Nerd Font"; ZipName = "JetBrainsMono"; Url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" },
    @{ Name = "FiraCode Nerd Font";      ZipName = "FiraCode";       Url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip" }
)

foreach ($font in $zipFonts) {
    $zipFile    = "$TempDir\$($font.ZipName).zip"
    $extractDir = "$TempDir\$($font.ZipName)"
    Write-Host "  Downloading $($font.Name)..."
    Invoke-WebRequest -Uri $font.Url -OutFile $zipFile -UseBasicParsing
    if (-not (Test-Path $extractDir)) { New-Item -ItemType Directory -Path $extractDir -Force | Out-Null }
    Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
    Get-ChildItem -Path $extractDir -Filter "*.ttf" -Recurse | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination "$FontsDir\$($_.Name)" -Force
    }
}

# Register all installed fonts in the registry.
# System fonts (HKLM): value is the filename only — Windows resolves against C:\Windows\Fonts.
# User fonts (HKCU):   value is the full path — Windows has no fixed resolution dir for user fonts.
Get-ChildItem -Path $FontsDir -Filter "*.ttf" | ForEach-Object {
    $fontRegName = $_.BaseName + " (TrueType)"
    $fontRegVal  = if ($FontScope -eq "system") { $_.Name } else { $_.FullName }
    Set-ItemProperty -Path $RegPath -Name $fontRegName -Value $fontRegVal -ErrorAction SilentlyContinue
}

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# 4. VERIFY
if (Test-Path $MarkerFile) {
    Write-Host "$APP_NAME installed successfully ($FontScope)."
    if ($FontScope -eq "user") {
        Write-Host "  Note: fonts installed per-user. Elevated (admin) terminals may not see them."
        Write-Host "  Re-run setup as Administrator to install fonts system-wide."
    }
} else {
    Write-Error "$APP_NAME installation failed - marker file not found: $MarkerFile"
    exit 1
}
