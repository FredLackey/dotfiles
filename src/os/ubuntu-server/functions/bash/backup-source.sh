#!/bin/bash
# Back up the ~/Source directory using rsync.
#
# Usage:
#   backup-source /path/to/backups/

backup-source() {
    local backupdir="$*$(date +"%Y%m%d%H%M%S")/"
    local backupcmd="rsync -arv --progress --no-links --exclude={.Trash,.android,.atom,.bash_sessions,.cache,.cups,.dropbox,.git,.next,.npm,.nvm,.viminfo,bower_components,node_modules,.tmp,.idea,.DS_Store,.terraform} ~/Source $backupdir"
    mkdir -p "$backupdir"
    eval "$backupcmd"
    cd "$backupdir"
}
