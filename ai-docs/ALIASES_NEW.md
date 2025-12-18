# Proposed Bash Aliases Reorganization

## Universal Aliases (bash_aliases)

All universal aliases go in the main bash_aliases file, regardless of application dependencies:

```bash
# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."

# File Operations
alias cp="cp -iv"
alias mkdir="mkdir -pv"
alias mv="mv -iv"
alias rm="rm -rf --"

# Common Shortcuts
alias :q="exit"
alias c="clear"
alias ch="history -c && > ~/.bash_history"
alias d="cd ~/Desktop"
alias e="vim --"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ll="ls -l"
alias m="man"
alias map="xargs -n1"
alias n="npm"
alias p="cd ~/projects"
alias path='printf "%b\n" "${PATH//:/\\n}"'
alias q="exit"
alias t="tmux"
alias y="yarn"

# File/Directory Counting
alias count-files="find . -maxdepth 1 -type f | wc -l"
alias count-folders="find . -mindepth 1 -maxdepth 1 -type d | wc -l"
alias count='echo "Files  : $(find . -maxdepth 1 -type f | wc -l)" && echo "Folders: $(find . -mindepth 1 -maxdepth 1 -type d | wc -l)"'

# Safety Override
alias rm='rm_safe'
```

**Note:** `dp` is a function in bash_functions with Docker availability check.

## macOS-Specific

```bash
alias afk="osascript -e 'tell application \"System Events\" to sleep'"
alias brewd="brew doctor"
alias brewi="brew install"
alias brewr="brew uninstall"
alias brews="brew search"
alias brewu="brew update --quiet && brew upgrade && brew cleanup"
alias clear-dns-cache="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias empty-trash="sudo rm -frv /Volumes/*/.Trashes; sudo rm -frv ~/.Trash; sudo rm -frv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"
alias hide-desktop-icons="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias show-desktop-icons="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hide-hidden-files="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias show-hidden-files="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias o="open"
alias u="sudo softwareupdate --install --all && brew update && brew upgrade && brew cleanup"
alias iso="TZ=America/Los_Angeles date -Iseconds"
alias local-ip="ipconfig getifaddr en1"
alias ports="lsof -i -P -n"
alias code-all="find . -type d -depth 1 -exec code {} \;"
alias packages="find ./ -type f -name \"package.json\" -exec stat -f \"%Sm %N\" -t \"%Y-%m-%d %H:%M:%S\" {} + | grep -v \"node_modules\" | sort -n"
```

## Ubuntu/Linux-Specific

```bash
alias afk="gnome-screensaver-command --lock"
alias apti="sudo apt-get install"
alias aptr="sudo apt-get remove"
alias apts="sudo apt-cache search"
alias aptu="sudo apt-get update && sudo apt-get upgrade"
alias empty-trash="rm -rf ~/.local/share/Trash/files/*"
alias u="sudo apt-get update && sudo apt-get upgrade"
alias packages="find ./ -type f -name \"package.json\" -exec stat --format=\"%Y %n\" {} + | grep -v \"node_modules\" sort -n | awk '{print strftime(\"%Y-%m-%d %H:%M:%S\", \$1), \$2}'"
alias local-ip='hostname -I | awk '\''{print $1}'\'''
alias myip='curl -s https://ipinfo.io/ip'
```

## Raspberry Pi-Specific (in addition to Ubuntu aliases)

```bash
alias pi-temp='vcgencmd measure_temp'
alias pi-throttle='vcgencmd get_throttled'
alias pi-version='cat /proc/device-tree/model'
```
