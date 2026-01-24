#!/bin/zsh
# npmi - Reinstall npm dependencies with nvm Node v18
#
# Removes node_modules, switches to Node v18 via nvm, and runs npm install.
#
# Usage:
#   npmi
#
# Dependencies:
#   - npm (included with Node.js)
#   - nvm (https://github.com/nvm-sh/nvm)

npmi() {
    if [ ! -f "$PWD/package.json" ]; then
        echo "Not an NPM package folder."
        return 1
    fi

    if [ -e "$PWD/node_modules" ]; then
        echo "Removing old node_modules folder..."
        rm -rf "$PWD/node_modules"
        if [ -e "$PWD/node_modules" ]; then
            echo "... failure!"
            return 1
        else
            echo "... done."
        fi
    fi

    echo "Setting Node v18 and installing..."

    # Load nvm
    export NVM_DIR=$HOME/.nvm
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        source "$NVM_DIR/nvm.sh"
    else
        echo "Error: nvm not found at $NVM_DIR/nvm.sh"
        return 1
    fi

    nvm use 18 && npm i

    if [ -e "$PWD/node_modules" ]; then
        echo "... done."
    else
        echo "... failure!"
        return 1
    fi
}
