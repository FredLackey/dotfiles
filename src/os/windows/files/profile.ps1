# PowerShell Profile
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# Starship prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
