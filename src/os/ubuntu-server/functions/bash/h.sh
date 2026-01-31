#!/bin/bash
# Search history using grep and less.
#
# Usage:
#   h "git commit"

h() {
    grep --color=always "$*" "$HISTFILE" \
        | less --no-init --raw-control-chars
}
