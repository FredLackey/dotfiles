#!/bin/bash
set -e

APP_NAME="Shell Cosmetics"
DOTFILES_DIR="$HOME/.dotfiles"
FILES_DIR="$DOTFILES_DIR/src/os/macos/files"
INPUTRC_SOURCE="$FILES_DIR/.inputrc"
INPUTRC_TARGET="$HOME/.inputrc"

# 1. Check if already configured
if [ -L "$INPUTRC_TARGET" ] && [ "$(readlink "$INPUTRC_TARGET")" = "$INPUTRC_SOURCE" ]; then
    echo "$APP_NAME is already configured."
    exit 0
fi

# 2. Check dependencies
if [ ! -f "$INPUTRC_SOURCE" ]; then
    echo "Error: .inputrc source file not found at $INPUTRC_SOURCE"
    exit 1
fi

# 3. Deploy .inputrc
echo "Configuring $APP_NAME..."

# Back up existing .inputrc if it exists and is not a symlink
if [ -f "$INPUTRC_TARGET" ] && [ ! -L "$INPUTRC_TARGET" ]; then
    echo "Backing up existing .inputrc to .inputrc.bak"
    mv "$INPUTRC_TARGET" "$INPUTRC_TARGET.bak"
fi

# Create symlink
ln -sf "$INPUTRC_SOURCE" "$INPUTRC_TARGET"

# 4. Verify
if [ -L "$INPUTRC_TARGET" ] && [ "$(readlink "$INPUTRC_TARGET")" = "$INPUTRC_SOURCE" ]; then
    echo "$APP_NAME configured."
else
    echo "Error: Failed to configure $APP_NAME."
    exit 1
fi
