# h - Search PowerShell command history
#
# Usage:
#   h "git"
#   h "docker run"

function h {
    param(
        [Parameter(Position = 0)][string]$Pattern
    )

    $histFile = (Get-PSReadlineOption).HistorySavePath
    if (-not (Test-Path $histFile)) {
        Write-Host "No history file found at: $histFile"
        return
    }

    if ($Pattern) {
        Get-Content $histFile | Select-String -Pattern $Pattern -CaseSensitive:$false |
            Select-Object -ExpandProperty Line
    } else {
        Get-Content $histFile
    }
}
