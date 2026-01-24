#!/bin/bash
set -e

APP_NAME="NVM"

# 1. Check if already installed
# NVM is a shell function, so check for directory or brew package
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] || (command -v brew >/dev/null && brew list nvm &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
brew install --quiet nvm

# Create NVM directory
mkdir -p "$HOME/.nvm"

# 4. Verify
if brew list nvm &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi

# Note: Shell configuration (NVM loading) is handled by dotfiles shell config files.
# See: src/os/macos/files/.zshrc and src/os/macos/files/.bash_profile
