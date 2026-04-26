#!/bin/bash
# codex-update - Update Codex CLI via npm
#
# Updates Codex CLI to the latest version. By default it requires Codex to
# already be installed; pass --install to allow a fresh install.
#
# Usage:
#   codex-update
#   codex-update --install
#
# Dependencies:
#   - npm

codex-update() {
    local allow_install=false

    if [ "$1" = "--install" ]; then
        allow_install=true
        shift
    fi

    if [ "$#" -gt 0 ]; then
        echo "Usage: codex-update [--install]"
        return 1
    fi

    if [ "$allow_install" != true ] && ! command -v codex &> /dev/null; then
        echo "Codex is not currently installed."
        echo "Use codex-update --install to install it."
        return 1
    fi

    if ! command -v npm &> /dev/null; then
        echo "npm is not currently installed."
        echo "Cannot update Codex CLI without npm."
        return 1
    fi

    if [ "$allow_install" = true ]; then
        echo "Installing or updating Codex CLI to the latest version..."
    else
        echo "Updating Codex CLI to the latest version..."
    fi
    npm install -g @openai/codex@latest
}
