#!/bin/bash
set -e

APP_NAME="Tmux"
FILES_DIR="$HOME/.dotfiles/src/os/macos/files"
TMUX_SOURCE="$FILES_DIR/.tmux.conf"
TMUX_TARGET="$HOME/.tmux.conf"

# 1. Check if already installed and config is up to date
TMUX_INSTALLED=false
CONFIG_CURRENT=false

if command -v tmux >/dev/null 2>&1; then
    TMUX_INSTALLED=true
fi

if [ -f "$TMUX_TARGET" ] && diff -q "$TMUX_SOURCE" "$TMUX_TARGET" >/dev/null 2>&1; then
    CONFIG_CURRENT=true
fi

if [ "$TMUX_INSTALLED" = true ] && [ "$CONFIG_CURRENT" = true ]; then
    echo "$APP_NAME is already installed and configured."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

if [ ! -f "$TMUX_SOURCE" ]; then
    echo "Error: Source file not found: $TMUX_SOURCE"
    exit 1
fi

# 3. Install
if [ "$TMUX_INSTALLED" = false ]; then
    echo "Installing $APP_NAME..."
    brew install --quiet tmux
fi

# 4. Deploy configuration
if [ "$CONFIG_CURRENT" = false ]; then
    echo "Deploying .tmux.conf..."
    cp "$TMUX_SOURCE" "$TMUX_TARGET"
    echo "  Deployed .tmux.conf"
fi

# 5. Verify
if command -v tmux >/dev/null 2>&1 && diff -q "$TMUX_SOURCE" "$TMUX_TARGET" >/dev/null 2>&1; then
    echo "$APP_NAME installed and configured successfully."
else
    echo "Error: $APP_NAME installation or configuration failed."
    exit 1
fi
