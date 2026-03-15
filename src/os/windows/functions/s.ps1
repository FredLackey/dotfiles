# s - Search for text recursively in the current directory
#
# Usage:
#   s "search term"
#   s "pattern.*regex"

function s {
    param(
        [Parameter(Mandatory, Position = 0)][string]$Pattern
    )

    Get-ChildItem -Path . -File -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\\.git\\|\\node_modules\\' } |
        Select-String -Pattern $Pattern -CaseSensitive:$false |
        ForEach-Object {
            Write-Host "$($_.Path):$($_.LineNumber): $($_.Line.Trim())"
        }
}
