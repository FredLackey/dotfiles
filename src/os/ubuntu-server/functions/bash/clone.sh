#!/bin/bash
# Clone a repository and install its dependencies.
#
# Usage:
#   clone https://github.com/user/repo.git

clone() {
    git clone "$1" || return

    cd "$(basename "${1%.*}")" || return

    # Check if there are dependencies to be installed
    if [ ! -f "package.json" ]; then
        return
    fi

    # Check if the project uses Yarn
    if [ -f "yarn.lock" ] && command -v yarn &>/dev/null; then
        printf "\n"
        yarn install
        return
    fi

    # If not, assume it uses npm
    if command -v npm &>/dev/null; then
        printf "\n"
        npm install
    fi
}
