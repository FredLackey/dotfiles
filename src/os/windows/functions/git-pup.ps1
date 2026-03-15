# git-pup - Pull and update all submodules
#
# Usage:
#   git-pup

function git-pup {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "git is required but not installed."
        return
    }
    if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
        Write-Error "Not in a git repository."
        return
    }

    git pull
    git submodule init
    git submodule update
    git submodule status
}
