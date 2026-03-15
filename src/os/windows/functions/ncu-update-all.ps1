# ncu-update-all - Run npm-check-updates on all package.json files recursively
#
# Usage:
#   ncu-update-all

function ncu-update-all {
    if (-not (Get-Command ncu -ErrorAction SilentlyContinue)) {
        Write-Error "npm-check-updates is required. Install with: npm install -g npm-check-updates"
        return
    }

    Get-ChildItem -Path . -Name "package.json" -Recurse |
        Where-Object { $_ -notmatch "node_modules|bower_components" } |
        ForEach-Object {
            $dir = Split-Path (Join-Path (Get-Location) $_) -Parent
            Write-Host "`nUpdating $dir..."
            Push-Location $dir
            ncu -u
            Pop-Location
        }
}
