#!/bin/bash
set -e

APP_NAME="Starship Config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$SCRIPT_DIR/../files"
CONFIG_SRC="$FILES_DIR/starship.toml"
CONFIG_DEST="$HOME/.config/starship.toml"

# 1. CHECK
if [ -L "$CONFIG_DEST" ]; then
    current=$(readlink "$CONFIG_DEST")
    if [ "$current" = "$CONFIG_SRC" ]; then
        echo "$APP_NAME is already up to date."
        exit 0
    fi
fi

echo "Installing $APP_NAME..."

# 2. DEPENDENCIES
if [ ! -f "$CONFIG_SRC" ]; then
    echo "Error: Source file not found: $CONFIG_SRC"
    exit 1
fi

# 3. INSTALL
mkdir -p "$HOME/.config"
[ -L "$CONFIG_DEST" ] && rm "$CONFIG_DEST"
[ -f "$CONFIG_DEST" ] && mv "$CONFIG_DEST" "${CONFIG_DEST}.backup"
ln -s "$CONFIG_SRC" "$CONFIG_DEST"

# 4. VERIFY
if [ -L "$CONFIG_DEST" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
