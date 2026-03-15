# clone - Clone a repository and install dependencies
#
# Usage:
#   clone git@github.com:org/repo.git
#   clone git@github.com:org/repo.git my-folder

function clone {
    param(
        [Parameter(Mandatory, Position = 0)][string]$RepoUrl,
        [Parameter(Position = 1)][string]$Destination
    )

    if ($Destination) {
        git clone $RepoUrl $Destination
        Set-Location $Destination
    } else {
        git clone $RepoUrl
        $folderName = [System.IO.Path]::GetFileNameWithoutExtension($RepoUrl.TrimEnd('/').Split('/')[-1])
        Set-Location $folderName
    }

    if (Test-Path "package.json") {
        if (Get-Command yarn -ErrorAction SilentlyContinue) {
            yarn install
        } else {
            npm install
        }
    }
}
