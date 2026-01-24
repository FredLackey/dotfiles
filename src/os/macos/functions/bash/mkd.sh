#!/bin/bash
# mkd - Create a new directory and cd into it
#
# Usage:
#   mkd my-project
#
# Dependencies: None (uses built-in commands)

mkd() {
    if [ -z "$1" ]; then
        echo "Usage: mkd <directory-name>"
        return 1
    fi

    mkdir -p "$@" && cd "$@"
}
