#!/bin/bash
# Reinstall npm dependencies after removing node_modules.
#
# Usage:
#   npmi

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

    if ! command -v npm >/dev/null 2>&1; then
        echo "npm is not installed."
        return 1
    fi

    echo "Installing dependencies with the system Node.js..."
    npm i

    if [ -e "$PWD/node_modules" ]; then
        echo "... done."
    else
        echo "... failure!"
        return 1
    fi
}
