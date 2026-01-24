#!/bin/zsh
# s - Search for text in current directory recursively
#
# Searches recursively, excluding .git and node_modules directories.
#
# Usage:
#   s "my_variable"
#
# Dependencies:
#   - grep (pre-installed on macOS)
#   - less (pre-installed on macOS)

s() {
    if [ -z "$1" ]; then
        echo "Usage: s <search-term>"
        return 1
    fi

    grep --color=always "$*" \
        --exclude-dir=".git" \
        --exclude-dir="node_modules" \
        --ignore-case \
        --recursive \
        . \
        | less --no-init --raw-control-chars
}
