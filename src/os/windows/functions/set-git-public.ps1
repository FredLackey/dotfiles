# set-git-public - Set git user to public identity
#
# Usage:
#   set-git-public

function set-git-public {
    git config user.email "fred.lackey@gmail.com"
    git config user.name "Fred Lackey"
    Write-Host "Git user set to: Fred Lackey <fred.lackey@gmail.com>"
}
