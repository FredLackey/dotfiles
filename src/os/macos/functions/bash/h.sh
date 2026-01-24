#!/bin/bash
# h - Search command history with grep and paging
#
# Usage:
#   h "git commit"
#
# Dependencies:
#   - grep (pre-installed on macOS)
#   - less (pre-installed on macOS)

h() {
    if [ -z "$1" ]; then
        echo "Usage: h <search-term>"
        return 1
    fi

    if [ -z "$HISTFILE" ]; then
        echo "Error: HISTFILE is not set."
        return 1
    fi

    grep --color=always "$*" "$HISTFILE" \
        | less --no-init --raw-control-chars
}
