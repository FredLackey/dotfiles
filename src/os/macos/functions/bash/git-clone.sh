#!/bin/bash
# git-clone - Copy a repository structure without .git folder
#
# Usage:
#   git-clone /path/to/source/repo/
#
# Dependencies:
#   - rsync (pre-installed on macOS)

git-clone() {
    if [ -z "$1" ]; then
        echo "Usage: git-clone <source-path>"
        return 1
    fi

    rsync -av --progress "$@" ./ \
        --exclude .git \
        --exclude README.md \
        --exclude LICENSE \
        --exclude node_modules \
        --exclude bower_components
}
