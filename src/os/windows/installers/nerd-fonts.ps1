$ErrorActionPreference = "Stop"

$APP_NAME   = "Nerd Fonts"
$FontsDir   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$MarkerFile = "$FontsDir\MesloLGS-NF-Regular.ttf"

# 1. CHECK - Skip if already installed (marker is the MesloLGS NF Regular file)
if (Test-Path $MarkerFile) {
    Write-Host "$APP_NAME are already installed."
    exit 0
}

# 2. DEPENDENCIES - PowerShell and Invoke-WebRequest are built-in; no extra deps needed

# 3. INSTALL
Write-Host "Installing $APP_NAME..."

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

# Register all installed fonts in the user registry.
# For HKCU user fonts the value must be the full path (not just the filename),
# because Windows has no fixed resolution directory for user fonts the way it
# does for system fonts in C:\Windows\Fonts.
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
Get-ChildItem -Path $FontsDir -Filter "*.ttf" | ForEach-Object {
    $fontRegName = $_.BaseName + " (TrueType)"
    Set-ItemProperty -Path $regPath -Name $fontRegName -Value $_.FullName -ErrorAction SilentlyContinue
}

Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

# 4. VERIFY
if (Test-Path $MarkerFile) {
    Write-Host "$APP_NAME installed successfully."
} else {
    Write-Error "$APP_NAME installation failed — marker file not found: $MarkerFile"
    exit 1
}
