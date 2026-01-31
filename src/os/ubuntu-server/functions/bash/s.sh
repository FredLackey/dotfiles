#!/bin/bash
# Search for text within the current directory using grep and less.
#
# Usage:
#   s "my_variable"

s() {
    grep --color=always "$*" \
         --exclude-dir=".git" \
         --exclude-dir="node_modules" \
         --ignore-case \
         --recursive \
         . \
        | less --no-init --raw-control-chars
}
