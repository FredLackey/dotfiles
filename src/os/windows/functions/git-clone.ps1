# git-clone - Copy a repository's structure without the .git folder
#
# Useful for scaffolding a new project from an existing one.
# Excludes: .git, README.md, LICENSE, node_modules, bower_components
#
# Usage:
#   git-clone C:\source\repo C:\dest\new-project

function git-clone {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Source,
        [Parameter(Mandatory, Position = 1)][string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Error "Source not found: $Source"
        return
    }

    robocopy $Source $Destination /E `
        /XD .git node_modules bower_components `
        /XF README.md LICENSE `
        /NJH /NJS | Out-Null

    Write-Host "Copied $Source -> $Destination (without .git)"
}
