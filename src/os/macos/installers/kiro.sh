#!/bin/bash
set -e

APP_NAME="Kiro"
APP_PATH="/Applications/Kiro.app"

# 1. Check if already installed
if [ -d "$APP_PATH" ] || (command -v brew >/dev/null && brew list --cask kiro &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
brew install --cask --quiet kiro

# 4. Verify
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
