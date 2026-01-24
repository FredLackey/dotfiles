#!/bin/zsh
# backup-source - Back up ~/Source directory using rsync
#
# Creates a timestamped backup directory and copies ~/Source with exclusions.
#
# Usage:
#   backup-source /path/to/backups/
#
# Excludes: .Trash, .android, .atom, .bash_sessions, .cache, .cups, .dropbox,
#           .git, .next, .npm, .nvm, .viminfo, bower_components, node_modules,
#           .tmp, .idea, .DS_Store, .terraform
#
# Dependencies:
#   - rsync (pre-installed on macOS)

backup-source() {
    if [ -z "$1" ]; then
        echo "Usage: backup-source <backup-destination>"
        return 1
    fi

    local backupdir="$1$(date +"%Y%m%d%H%M%S")/"

    mkdir -p "$backupdir"

    rsync -arv --progress --no-links \
        --exclude=.Trash \
        --exclude=.android \
        --exclude=.atom \
        --exclude=.bash_sessions \
        --exclude=.cache \
        --exclude=.cups \
        --exclude=.dropbox \
        --exclude=.git \
        --exclude=.next \
        --exclude=.npm \
        --exclude=.nvm \
        --exclude=.viminfo \
        --exclude=bower_components \
        --exclude=node_modules \
        --exclude=.tmp \
        --exclude=.idea \
        --exclude=.DS_Store \
        --exclude=.terraform \
        ~/Source "$backupdir"

    cd "$backupdir"
    echo "Backup completed: $backupdir"
}
