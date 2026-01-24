#!/bin/bash
set -e

APP_NAME="Shell Config"
FILES_DIR="$HOME/.dotfiles/src/os/macos/files"

# Files to deploy
ZSHRC_SOURCE="$FILES_DIR/.zshrc"
BASH_PROFILE_SOURCE="$FILES_DIR/.bash_profile"

ZSHRC_TARGET="$HOME/.zshrc"
BASH_PROFILE_TARGET="$HOME/.bash_profile"

# 1. Check if already up to date
ZSHRC_CURRENT=true
BASH_PROFILE_CURRENT=true

if [ ! -f "$ZSHRC_TARGET" ] || ! diff -q "$ZSHRC_SOURCE" "$ZSHRC_TARGET" >/dev/null 2>&1; then
    ZSHRC_CURRENT=false
fi

if [ ! -f "$BASH_PROFILE_TARGET" ] || ! diff -q "$BASH_PROFILE_SOURCE" "$BASH_PROFILE_TARGET" >/dev/null 2>&1; then
    BASH_PROFILE_CURRENT=false
fi

if [ "$ZSHRC_CURRENT" = true ] && [ "$BASH_PROFILE_CURRENT" = true ]; then
    echo "$APP_NAME is already up to date."
    exit 0
fi

# 2. Check dependencies
if [ ! -f "$ZSHRC_SOURCE" ]; then
    echo "Error: Source file not found: $ZSHRC_SOURCE"
    exit 1
fi

if [ ! -f "$BASH_PROFILE_SOURCE" ]; then
    echo "Error: Source file not found: $BASH_PROFILE_SOURCE"
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

cp "$ZSHRC_SOURCE" "$ZSHRC_TARGET"
echo "  Deployed .zshrc"

cp "$BASH_PROFILE_SOURCE" "$BASH_PROFILE_TARGET"
echo "  Deployed .bash_profile"

# 4. Verify
if diff -q "$ZSHRC_SOURCE" "$ZSHRC_TARGET" >/dev/null 2>&1 && \
   diff -q "$BASH_PROFILE_SOURCE" "$BASH_PROFILE_TARGET" >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
