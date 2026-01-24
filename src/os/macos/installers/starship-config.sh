#!/bin/bash
set -e

APP_NAME="Starship Config"
SOURCE="$HOME/.dotfiles/src/os/macos/files/starship.toml"
TARGET="$HOME/.config/starship.toml"

# 1. Check if already up to date
if [ -f "$TARGET" ] && diff -q "$SOURCE" "$TARGET" >/dev/null 2>&1; then
    echo "$APP_NAME is already up to date."
    exit 0
fi

# 2. Check dependencies
if ! command -v starship >/dev/null; then
    echo "Error: Starship is required before installing $APP_NAME."
    exit 1
fi

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source config not found: $SOURCE"
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
mkdir -p "$HOME/.config"
cp "$SOURCE" "$TARGET"

# 4. Verify
if diff -q "$SOURCE" "$TARGET" >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
