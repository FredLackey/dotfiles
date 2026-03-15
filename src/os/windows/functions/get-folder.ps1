# get-folder - Copy files from source to destination, skipping files that already exist
#
# Usage:
#   get-folder C:\source\assets C:\dest\assets

function get-folder {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Source,
        [Parameter(Mandatory, Position = 1)][string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Error "Source not found: $Source"
        return
    }

    # /XO = exclude older (skip if destination file is same age or newer)
    # /E  = include empty subdirectories
    robocopy $Source $Destination /XO /E /NJH /NJS
}
