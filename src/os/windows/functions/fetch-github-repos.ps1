# fetch-github-repos - Clone all repositories from a GitHub organization or user
#
# Usage:
#   fetch-github-repos my-org
#   fetch-github-repos my-username

function fetch-github-repos {
    param(
        [Parameter(Mandatory, Position = 0)][string]$OrgOrUser
    )

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is required but not installed."
        return
    }

    $repos = gh repo list $OrgOrUser --limit 200 --json nameWithOwner 2>$null | ConvertFrom-Json
    if (-not $repos) {
        Write-Host "No repositories found for: $OrgOrUser"
        return
    }

    foreach ($repo in $repos) {
        $name = $repo.nameWithOwner.Split('/')[-1]
        if (-not (Test-Path $name)) {
            Write-Host "Cloning $($repo.nameWithOwner)..."
            git clone "git@github.com:$($repo.nameWithOwner).git"
        } else {
            Write-Host "Already exists: $name"
        }
    }
}
