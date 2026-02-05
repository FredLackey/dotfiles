#!/bin/bash
set -e

APP_NAME="tmux"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$SCRIPT_DIR/../files"
TMUX_SOURCE="$FILES_DIR/.tmux.conf"
TMUX_TARGET="$HOME/.tmux.conf"

# 1. Check if already installed and config is up to date
TMUX_INSTALLED=false
CONFIG_CURRENT=false

if command -v tmux >/dev/null 2>&1; then
    TMUX_INSTALLED=true
fi

if [ -L "$TMUX_TARGET" ]; then
    current_target=$(readlink "$TMUX_TARGET")
    if [ "$current_target" = "$TMUX_SOURCE" ]; then
        CONFIG_CURRENT=true
    fi
fi

if [ "$TMUX_INSTALLED" = true ] && [ "$CONFIG_CURRENT" = true ]; then
    echo "$APP_NAME is already installed and configured."
    exit 0
fi

# 2. Check dependencies
if [ ! -f "$TMUX_SOURCE" ]; then
    echo "Error: Source file not found: $TMUX_SOURCE"
    exit 1
fi

# 3. Install
if [ "$TMUX_INSTALLED" = false ]; then
    echo "Installing $APP_NAME..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq tmux
fi

# 4. Deploy configuration
if [ "$CONFIG_CURRENT" = false ]; then
    echo "Deploying .tmux.conf..."
    if [ -f "$TMUX_TARGET" ] && [ ! -L "$TMUX_TARGET" ]; then
        echo "  Backing up existing .tmux.conf to .tmux.conf.backup"
        mv "$TMUX_TARGET" "${TMUX_TARGET}.backup"
    elif [ -L "$TMUX_TARGET" ]; then
        rm "$TMUX_TARGET"
    fi
    ln -s "$TMUX_SOURCE" "$TMUX_TARGET"
    echo "  Linked .tmux.conf"
fi

# 5. Verify
if command -v tmux >/dev/null 2>&1 && [ -L "$TMUX_TARGET" ]; then
    echo "$APP_NAME installed and configured successfully."
else
    echo "Error: $APP_NAME installation or configuration failed."
    exit 1
fi
