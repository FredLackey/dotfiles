# vpush - Commit and push using the version from package.json as the commit message
#
# Usage:
#   vpush

function vpush {
    if (-not (Test-Path "package.json")) {
        Write-Error "No package.json found in current directory."
        return
    }

    $version = (Get-Content "package.json" -Raw | ConvertFrom-Json).version
    if (-not $version) {
        Write-Error "No version field found in package.json."
        return
    }

    Write-Host "Committing as version $version..."
    git add -A
    git commit -S -m $version
    git push origin master
}
