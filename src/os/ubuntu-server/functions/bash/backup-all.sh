#!/bin/bash
# Back up various user directories using rsync.
#
# Usage:
#   backup-all /path/to/backups/

backup-all() {
    local excludes=".terraform,.android,.atom,.bash_sessions,bower_components,.cache,.cups,.dropbox,.DS_Store,.git,_gsdata_,.idea,node_modules,.next,.npm,.nvm,\$RECYCLE.BIN,System\ Volume\ Information,.TemporaryItems,.Trash,.Trashes,.tmp,.viminfo"

    local backupdir="$*"
    local backupcmd="rsync -arv --progress --no-links --exclude={$excludes} ~/Downloads $backupdir"
    eval "$backupcmd"

    backupdir="$*$(date +"%Y%m%d%H%M%S")/"
    backupcmd="rsync -arv --progress --no-links --exclude={$excludes} ~/Backups ~/Desktop ~/Documents ~/Microsoft ~/Movies ~/Music ~/Pictures ~/Public ~/Source ~/Templates ~/Temporary ~/Videos $backupdir"
    mkdir -p "$backupdir"
    eval "$backupcmd"

    cd "$backupdir"
    ls -la
}
