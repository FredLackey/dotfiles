# install-dependencies-from - Install dependencies from another package.json into the current project
#
# Usage:
#   install-dependencies-from ../other/package.json
#   install-dependencies-from ../other/package.json -Type devDependencies

function install-dependencies-from {
    param(
        [Parameter(Mandatory, Position = 0)][string]$File,
        [ValidateSet("dependencies","devDependencies","peerDependencies","optionalDependencies","all")]
        [string]$Type = "all"
    )

    if (-not (Test-Path $File)) {
        Write-Error "File not found: $File"
        return
    }

    $pkg = Get-Content $File -Raw | ConvertFrom-Json

    $typeFlags = @{
        "dependencies"         = @()
        "devDependencies"      = @("--save-dev")
        "peerDependencies"     = @("--save-peer")
        "optionalDependencies" = @("--save-optional")
    }

    $types = if ($Type -eq "all") { $typeFlags.Keys } else { @($Type) }

    foreach ($t in $types) {
        if ($pkg.$t) {
            $deps  = $pkg.$t.PSObject.Properties | ForEach-Object { "$($_.Name)@$($_.Value)" }
            $flags = $typeFlags[$t]
            Write-Host "Installing $t..."
            if ($flags) {
                npm install @flags @deps
            } else {
                npm install @deps
            }
        }
    }
}
