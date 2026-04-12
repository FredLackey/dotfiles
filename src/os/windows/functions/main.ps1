# Windows functions loader
# Dot-sourced by $PROFILE -- installed by dotfiles: https://github.com/FredLackey/dotfiles

$_FunctionsDir = "$HOME\.dotfiles\src\os\windows\functions"

# Exclusion check -- inline so dot-source in the loop runs in script scope, not function scope
function _dotfiles_is_excluded {
    param([string]$Category)
    if (-not $env:DOTFILES_EXCLUDE) { return $false }
    $excludeUpper  = $env:DOTFILES_EXCLUDE.ToUpper()
    $categoryUpper = $Category.ToUpper()
    return ",$excludeUpper," -like "*,$categoryUpper,*"
}

# Each entry: Category, File
# The dot-source MUST happen here in the script body (not inside a function) so
# the loaded functions land in the caller's scope rather than a transient child scope.
$_entries = @(
    # Utilities
    "UTILS", "rmrf.ps1",
    "UTILS", "ccurl.ps1",
    "UTILS", "datauri.ps1",
    "UTILS", "delete-files.ps1",
    "UTILS", "get-folder.ps1",
    "UTILS", "h.ps1",
    "UTILS", "ips.ps1",
    "UTILS", "mkd.ps1",
    "UTILS", "org-by-date.ps1",
    "UTILS", "refresh-files.ps1",
    "UTILS", "remove-smaller-files.ps1",
    "UTILS", "rename-files-with-date-in-name.ps1",
    "UTILS", "s.ps1",
    # AI Tools
    "AI",    "claude-danger.ps1",
    "AI",    "codex-danger.ps1",
    # Development
    "DEV",   "clean-dev.ps1",
    "DEV",   "clone.ps1",
    "DEV",   "fetch-github-repos.ps1",
    "DEV",   "get-dependencies.ps1",
    "DEV",   "git-backup.ps1",
    "DEV",   "git-clone.ps1",
    "DEV",   "git-pup.ps1",
    "DEV",   "git-push.ps1",
    "DEV",   "git-status.ps1",
    "DEV",   "install-dependencies-from.ps1",
    "DEV",   "killni.ps1",
    "DEV",   "ncu-update-all.ps1",
    "DEV",   "npmi.ps1",
    "DEV",   "set-git-public.ps1",
    "DEV",   "vpush.ps1",
    # DevOps
    "DEVOPS","docker-clean.ps1",
    "DEVOPS","dp.ps1",
    # Media
    "MEDIA", "get-channel.ps1",
    "MEDIA", "get-tunes.ps1",
    "MEDIA", "get-video.ps1",
    "MEDIA", "resize-image.ps1"
)

for ($i = 0; $i -lt $_entries.Count; $i += 2) {
    $_cat  = $_entries[$i]
    $_file = $_entries[$i + 1]
    if (_dotfiles_is_excluded $_cat) { continue }
    $_path = Join-Path $_FunctionsDir $_file
    if (Test-Path $_path) { . $_path }
}

Remove-Item Function:\_dotfiles_is_excluded -ErrorAction SilentlyContinue
Remove-Variable _FunctionsDir, _entries, _cat, _file, _path -ErrorAction SilentlyContinue
