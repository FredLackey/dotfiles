# mkd - Create a directory and immediately change into it
#
# Usage:
#   mkd new-folder
#   mkd path\to\new\folder

function mkd {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path
    )
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}
