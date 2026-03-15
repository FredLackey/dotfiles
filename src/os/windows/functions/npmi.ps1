# npmi - Clean reinstall of npm dependencies
#
# Removes node_modules and runs a fresh npm install.
#
# Usage:
#   npmi

function npmi {
    if (Test-Path "node_modules") {
        Write-Host "Removing node_modules..."
        Remove-Item -Path "node_modules" -Recurse -Force
    }
    Write-Host "Running npm install..."
    npm install
}
