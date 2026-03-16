#!/bin/bash
# Clone a repository structure without the .git folder using rsync.
#
# Usage:
#   git-clone /path/to/source/repo/

git-clone() {
    rsync -av --progress "$@" ./ --exclude .git --exclude README.md --exclude LICENSE --exclude node_modules --exclude bower_components
}
