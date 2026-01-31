#!/bin/bash
# Delete files that match a certain pattern from the current directory.
#
# Usage:
#   delete-files "*.log"  # Delete all .log files
#   delete-files          # Delete all .DS_Store files (default)

delete-files() {
    local q="${1:-*.DS_Store}"
    find . -type f -name "$q" -ls -delete
}
