# delete-files - Delete files matching a pattern recursively
#
# Usage:
#   delete-files           # Deletes all *.tmp files
#   delete-files "*.log"
#   delete-files "Thumbs.db"

function delete-files {
    param(
        [Parameter(Position = 0)][string]$Pattern = "*.tmp"
    )

    Get-ChildItem -Path . -Filter $Pattern -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            Write-Host "Removing $($_.FullName)"
            Remove-Item -Path $_.FullName -Force
        }
}
