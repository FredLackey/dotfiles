# PowerShell Profile
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Custom functions
$_functionsMain = "$HOME\.dotfiles\src\os\windows\functions\main.ps1"
if (Test-Path $_functionsMain) {
    . $_functionsMain
}
Remove-Variable _functionsMain -ErrorAction SilentlyContinue

# Aliases
Set-Alias -Name cc -Value claude-danger
Set-Alias -Name co -Value codex-danger
