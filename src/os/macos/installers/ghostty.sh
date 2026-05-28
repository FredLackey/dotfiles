#!/bin/bash
set -e

APP_NAME="Ghostty"
APP_PATH="/Applications/Ghostty.app"
CONFIG_SOURCE="$HOME/.dotfiles/src/os/macos/files/ghostty/config.ghostty"
CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
CONFIG_TARGET="$CONFIG_DIR/config.ghostty"

APP_INSTALLED=false
CONFIG_CURRENT=false

if [ -d "$APP_PATH" ] || (command -v brew >/dev/null && brew list --cask ghostty &>/dev/null); then
    APP_INSTALLED=true
fi

if [ -f "$CONFIG_TARGET" ] && diff -q "$CONFIG_SOURCE" "$CONFIG_TARGET" >/dev/null 2>&1; then
    CONFIG_CURRENT=true
fi

# 1. Check if already installed and configured
if [ "$APP_INSTALLED" = true ] && [ "$CONFIG_CURRENT" = true ]; then
    echo "$APP_NAME is already installed and configured."
    exit 0
fi

# 2. Check dependencies
if [ ! -f "$CONFIG_SOURCE" ]; then
    echo "Error: Source file not found: $CONFIG_SOURCE"
    exit 1
fi

if [ "$APP_INSTALLED" = false ] && ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install and configure
if [ "$APP_INSTALLED" = false ]; then
    echo "Installing $APP_NAME..."
    brew install --cask --quiet ghostty
else
    echo "$APP_NAME is already installed."
fi

if [ "$CONFIG_CURRENT" = false ]; then
    mkdir -p "$CONFIG_DIR"
    cp "$CONFIG_SOURCE" "$CONFIG_TARGET"
    echo "  Deployed config.ghostty"
fi

# 4. Verify
if [ -d "$APP_PATH" ] && diff -q "$CONFIG_SOURCE" "$CONFIG_TARGET" >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
