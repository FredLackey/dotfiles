# get-dependencies - Extract dependency names from package.json
#
# Usage:
#   get-dependencies                           # All dependency types
#   get-dependencies -Type dependencies        # Production only
#   get-dependencies -Type devDependencies
#   get-dependencies -File ../other/package.json

function get-dependencies {
    param(
        [string]$File = "package.json",
        [ValidateSet("dependencies","devDependencies","peerDependencies","optionalDependencies","bundledDependencies","all")]
        [string]$Type = "all"
    )

    if (-not (Test-Path $File)) {
        Write-Error "File not found: $File"
        return
    }

    $pkg   = Get-Content $File -Raw | ConvertFrom-Json
    $types = if ($Type -eq "all") {
        @("dependencies","devDependencies","peerDependencies","optionalDependencies","bundledDependencies")
    } else {
        @($Type)
    }

    foreach ($t in $types) {
        if ($pkg.$t) {
            $pkg.$t.PSObject.Properties.Name | ForEach-Object { Write-Output $_ }
        }
    }
}
