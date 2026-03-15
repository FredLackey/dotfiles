# rename-files-with-date-in-name - Rename files to standardized date format
#
# Converts filenames like 20200505_050505.dng or "Screenshot 2020-05-06 at 10.30.00.png"
# to the standard format: "2020-05-05 05.05.05.dng"
#
# Usage:
#   rename-files-with-date-in-name         # Current directory
#   rename-files-with-date-in-name C:\path

function rename-files-with-date-in-name {
    param(
        [Parameter(Position = 0)][string]$Path = "."
    )

    Get-ChildItem -Path $Path -File | ForEach-Object {
        $base = $_.BaseName
        $ext  = $_.Extension
        $new  = $null

        # Format: 20200505_050505 (YYYYMMDD_HHMMSS)
        if ($base -match '^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})') {
            $new = "$($Matches[1])-$($Matches[2])-$($Matches[3]) $($Matches[4]).$($Matches[5]).$($Matches[6])$ext"
        }
        # Format: Screenshot 2020-05-06 at 10.30.00
        elseif ($base -match 'Screenshot (\d{4}-\d{2}-\d{2}) at (\d{2}\.\d{2}\.\d{2})') {
            $new = "$($Matches[1]) $($Matches[2])$ext"
        }

        if ($new -and $new -ne $_.Name) {
            $newPath = Join-Path $_.DirectoryName $new
            Write-Host "Renaming: $($_.Name) -> $new"
            Rename-Item -Path $_.FullName -NewName $new
        }
    }
}
