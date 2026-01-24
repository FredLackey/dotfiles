#!/bin/bash
# git-pup - Pull changes and update git submodules
#
# Usage:
#   git-pup
#
# Dependencies:
#   - git (brew install git)

git-pup() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not in a git repository."
        return 1
    fi

    git pull && git submodule init && git submodule update && git submodule status
}
