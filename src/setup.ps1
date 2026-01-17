$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/FredLackey/dotfiles/archive/refs/heads/main.zip"
$TargetDir = "$HOME\.dotfiles"
$TempFile = "$env:TEMP\dotfiles.zip"

if (-Not (Test-Path $TargetDir)) {
    Write-Host "Downloading dotfiles..."
    Invoke-WebRequest -Uri $RepoUrl -OutFile $TempFile
    Expand-Archive -Path $TempFile -DestinationPath $env:TEMP -Force
    Move-Item -Path "$env:TEMP\dotfiles-main" -Destination $TargetDir
    Remove-Item $TempFile
}

$ScriptDir = $PSScriptRoot
if (-Not (Test-Path "$ScriptDir\setup\windows\setup.ps1")) {
    $ScriptDir = "$TargetDir\src"
}

$ScriptToRun = "$ScriptDir\setup\windows\setup.ps1"
if (Test-Path $ScriptToRun) {
    & $ScriptToRun
} else {
    Write-Error "Could not find setup script: $ScriptToRun"
}
