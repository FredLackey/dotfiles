# clean-dev - Recursively remove node_modules and bower_components
#
# Usage:
#   clean-dev

function clean-dev {
    $targets = @("node_modules", "bower_components")
    foreach ($target in $targets) {
        Get-ChildItem -Path . -Filter $target -Recurse -Directory -Force -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-Host "Removing $($_.FullName)"
                Remove-Item -Path $_.FullName -Recurse -Force
            }
    }
    Write-Host "Done."
}
