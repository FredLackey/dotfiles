#!/bin/zsh
# clone - Clone a repository and automatically install dependencies
#
# Usage:
#   clone https://github.com/user/repo.git
#
# Dependencies:
#   - git (brew install git)
#   - npm (included with Node.js)
#   - yarn (optional - npm install -g yarn)

clone() {
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: clone <repository-url>"
        return 1
    fi

    git clone "$1" || return

    cd "$(basename "${1%.*}")" || return

    # Check if there are dependencies to be installed
    if [ ! -f "package.json" ]; then
        return
    fi

    # Check if the project uses Yarn
    if [ -f "yarn.lock" ] && command -v yarn &> /dev/null; then
        printf "\n"
        yarn install
        return
    fi

    # If not, assume it uses npm
    if command -v npm &> /dev/null; then
        printf "\n"
        npm install
    fi
}
