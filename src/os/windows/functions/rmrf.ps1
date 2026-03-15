# rmrf - Recursively and forcefully remove a file or directory
#
# Usage:
#   rmrf folder
#   rmrf file.txt

function rmrf {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path
    )

    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }

    Remove-Item $Path -Recurse -Force
}
