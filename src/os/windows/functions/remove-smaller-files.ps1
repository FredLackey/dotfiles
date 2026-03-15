# remove-smaller-files - Compare files with another directory and remove the smaller copy
#
# Usage:
#   remove-smaller-files C:\other\dir

function remove-smaller-files {
    param(
        [Parameter(Mandatory, Position = 0)][string]$OtherDir
    )

    if (-not (Test-Path $OtherDir)) {
        Write-Error "Directory not found: $OtherDir"
        return
    }

    Get-ChildItem -Path . -File | ForEach-Object {
        $other = Join-Path $OtherDir $_.Name
        if (Test-Path $other) {
            $otherSize = (Get-Item $other).Length
            if ($_.Length -lt $otherSize) {
                Write-Host "Removing smaller: $($_.FullName) ($($_.Length) bytes < $otherSize bytes)"
                Remove-Item $_.FullName -Force
            } elseif ($otherSize -lt $_.Length) {
                Write-Host "Removing smaller: $other ($otherSize bytes < $($_.Length) bytes)"
                Remove-Item $other -Force
            }
        }
    }
}
