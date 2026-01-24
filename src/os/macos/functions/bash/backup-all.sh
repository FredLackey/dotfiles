#!/bin/bash
# backup-all - Back up multiple user directories using rsync
#
# Backs up Downloads (without timestamp) and multiple user directories
# (with timestamp) including Desktop, Documents, Movies, Music, Pictures, Source, etc.
#
# Usage:
#   backup-all /path/to/backups/
#
# Dependencies:
#   - rsync (pre-installed on macOS)

backup-all() {
    if [ -z "$1" ]; then
        echo "Usage: backup-all <backup-destination>"
        return 1
    fi

    local excludes=".terraform,.android,.atom,.bash_sessions,bower_components,.cache,.cups,.dropbox,.DS_Store,.git,_gsdata_,.idea,node_modules,.next,.npm,.nvm,\$RECYCLE.BIN,System Volume Information,.TemporaryItems,.Trash,.Trashes,.tmp,.viminfo"

    # Backup Downloads without timestamp
    local backupdir="$1"
    echo "Backing up Downloads to $backupdir..."
    rsync -arv --progress --no-links \
        --exclude={$excludes} \
        ~/Downloads "$backupdir"

    # Backup other directories with timestamp
    backupdir="$1$(date +"%Y%m%d%H%M%S")/"
    mkdir -p "$backupdir"

    echo "Backing up user directories to $backupdir..."
    rsync -arv --progress --no-links \
        --exclude={$excludes} \
        ~/Backups \
        ~/Desktop \
        ~/Documents \
        ~/Microsoft \
        ~/Movies \
        ~/Music \
        ~/Pictures \
        ~/Public \
        ~/Source \
        ~/Templates \
        ~/Temporary \
        ~/Videos \
        "$backupdir" 2>/dev/null

    cd "$backupdir"
    ls -la
    echo "Backup completed: $backupdir"
}
