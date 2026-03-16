# Windows functions loader
# Dot-sourced by $PROFILE — installed by dotfiles: https://github.com/FredLackey/dotfiles

$_FunctionsDir = "$HOME\.dotfiles\src\os\windows\functions"

function _dotfiles_is_excluded {
    param([string]$Category)
    if (-not $env:DOTFILES_EXCLUDE) { return $false }
    $excludeUpper  = $env:DOTFILES_EXCLUDE.ToUpper()
    $categoryUpper = $Category.ToUpper()
    return ",$excludeUpper," -like "*,$categoryUpper,*"
}

function _dotfiles_load {
    param([string]$File, [string]$Category = "")
    if ($Category -and (_dotfiles_is_excluded $Category)) { return }
    $path = Join-Path $_FunctionsDir $File
    if (Test-Path $path) { . $path }
}

# Categories: UTILS, AI, DEV, DEVOPS, MEDIA

# Utilities
_dotfiles_load "rmrf.ps1"                           "UTILS"
_dotfiles_load "ccurl.ps1"                          "UTILS"
_dotfiles_load "datauri.ps1"                        "UTILS"
_dotfiles_load "delete-files.ps1"                   "UTILS"
_dotfiles_load "get-folder.ps1"                     "UTILS"
_dotfiles_load "h.ps1"                              "UTILS"
_dotfiles_load "ips.ps1"                            "UTILS"
_dotfiles_load "mkd.ps1"                            "UTILS"
_dotfiles_load "org-by-date.ps1"                    "UTILS"
_dotfiles_load "refresh-files.ps1"                  "UTILS"
_dotfiles_load "remove-smaller-files.ps1"           "UTILS"
_dotfiles_load "rename-files-with-date-in-name.ps1" "UTILS"
_dotfiles_load "s.ps1"                              "UTILS"

# AI Tools
_dotfiles_load "claude-danger.ps1"                  "AI"

# Development
_dotfiles_load "clean-dev.ps1"                      "DEV"
_dotfiles_load "clone.ps1"                          "DEV"
_dotfiles_load "fetch-github-repos.ps1"             "DEV"
_dotfiles_load "get-dependencies.ps1"               "DEV"
_dotfiles_load "git-backup.ps1"                     "DEV"
_dotfiles_load "git-clone.ps1"                      "DEV"
_dotfiles_load "git-pup.ps1"                        "DEV"
_dotfiles_load "git-push.ps1"                       "DEV"
_dotfiles_load "git-status.ps1"                     "DEV"
_dotfiles_load "install-dependencies-from.ps1"      "DEV"
_dotfiles_load "killni.ps1"                         "DEV"
_dotfiles_load "ncu-update-all.ps1"                 "DEV"
_dotfiles_load "npmi.ps1"                           "DEV"
_dotfiles_load "set-git-public.ps1"                 "DEV"
_dotfiles_load "vpush.ps1"                          "DEV"

# DevOps
_dotfiles_load "docker-clean.ps1"                   "DEVOPS"
_dotfiles_load "dp.ps1"                             "DEVOPS"

# Media
_dotfiles_load "get-channel.ps1"                    "MEDIA"
_dotfiles_load "get-tunes.ps1"                      "MEDIA"
_dotfiles_load "get-video.ps1"                      "MEDIA"
_dotfiles_load "resize-image.ps1"                   "MEDIA"

Remove-Item Function:\_dotfiles_is_excluded -ErrorAction SilentlyContinue
Remove-Item Function:\_dotfiles_load        -ErrorAction SilentlyContinue
Remove-Variable _FunctionsDir               -ErrorAction SilentlyContinue
