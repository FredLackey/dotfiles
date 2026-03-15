# org-by-date - Organize files with dates in their names into YYYY\MM\DD folders
#
# Usage:
#   org-by-date         # Current directory
#   org-by-date C:\path

function org-by-date {
    param(
        [Parameter(Position = 0)][string]$Path = "."
    )

    Get-ChildItem -Path $Path -File | ForEach-Object {
        if ($_.Name -match '(\d{4})-(\d{2})-(\d{2})') {
            $year  = $Matches[1]
            $month = $Matches[2]
            $day   = $Matches[3]
            $dest  = Join-Path $Path "$year\$month\$day"
            if (-not (Test-Path $dest)) {
                New-Item -ItemType Directory -Path $dest -Force | Out-Null
            }
            Move-Item -Path $_.FullName -Destination $dest -Force
            Write-Host "Moved $($_.Name) -> $year\$month\$day\"
        }
    }
}
