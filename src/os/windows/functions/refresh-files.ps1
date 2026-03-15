# refresh-files - Overwrite files in destination only where the file already exists there
#
# Unlike get-folder which copies everything, this only updates files that already
# exist in both locations — useful for refreshing configs without adding new files.
#
# Usage:
#   refresh-files C:\source C:\destination

function refresh-files {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Source,
        [Parameter(Mandatory, Position = 1)][string]$Destination
    )

    if (-not (Test-Path $Source)) {
        Write-Error "Source not found: $Source"
        return
    }

    Get-ChildItem -Path $Source -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($Source.Length).TrimStart('\')
        $destFile = Join-Path $Destination $relative
        if (Test-Path $destFile) {
            Copy-Item -Path $_.FullName -Destination $destFile -Force
            Write-Host "Refreshed $relative"
        }
    }
}
