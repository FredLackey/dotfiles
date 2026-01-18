#!/bin/bash
set -e

APP_NAME="Superwhisper"
APP_PATH="/Applications/Superwhisper.app"

# Check if installed
if [ -d "$APP_PATH" ] || [ -d "/Applications/superwhisper.app" ] || (command -v brew >/dev/null && brew list --cask superwhisper &>/dev/null); then
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
brew install --cask --quiet superwhisper

# Verify
if [ -d "$APP_PATH" ] || [ -d "/Applications/superwhisper.app" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
