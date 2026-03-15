# git-push - Add all changes, commit, and push in one command
#
# Usage:
#   git-push "Fix bug #123"

function git-push {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Message
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is required but not installed."
        return
    }
    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Error "Not in a git repository."
        return
    }

    $changes = git status --porcelain 2>$null
    if (-not $changes) {
        Write-Host "No changes detected in repository."
        return
    }

    $branch = git symbolic-ref --short HEAD 2>$null
    if (-not $branch) {
        Write-Error "Could not determine current branch."
        return
    }

    Write-Host "Changes detected, proceeding with commit and push..."
    git add -A
    git commit -m $Message
    git push origin $branch
}
