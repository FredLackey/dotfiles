#!/bin/zsh
# delete-files - Delete files matching a pattern (default: .DS_Store)
#
# Usage:
#   delete-files "*.log"  # Delete all .log files
#   delete-files          # Delete all .DS_Store files (default)
#
# Dependencies: None (uses built-in find)

delete-files() {
    local pattern="${1:-*.DS_Store}"
    find . -type f -name "$pattern" -ls -delete
}
