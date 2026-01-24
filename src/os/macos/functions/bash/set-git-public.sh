#!/bin/bash
# set-git-public - Set git user to public defaults
#
# Usage:
#   set-git-public
#
# Dependencies:
#   - git (brew install git)

set-git-public() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    git config user.email "fred.lackey@gmail.com"
    git config user.name "Fred Lackey"

    echo "Git user configured:"
    echo "  Email: fred.lackey@gmail.com"
    echo "  Name:  Fred Lackey"
}
