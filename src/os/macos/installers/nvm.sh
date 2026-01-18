#!/bin/bash
set -e

APP_NAME="NVM"

# NVM is a shell function, so checking "command -v nvm" might fail if not loaded.
# Check existence of NVM_DIR or brew list.
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] || (command -v brew >/dev/null && brew list nvm &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --quiet nvm

# Create directory if it doesn't exist (brew usually handles this or tells you to)
mkdir -p ~/.nvm

if brew list nvm &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
