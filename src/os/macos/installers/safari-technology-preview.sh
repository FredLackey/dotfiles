#!/bin/bash
set -e

APP_NAME="Safari Technology Preview"
APP_PATH="/Applications/Safari Technology Preview.app"

# Check if installed
if [ -d "$APP_PATH" ] || (command -v brew >/dev/null && brew list --cask safari-technology-preview &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

# Check dependencies
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# Install
echo "Installing $APP_NAME..."
brew install --cask --quiet safari-technology-preview

# Verify
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
