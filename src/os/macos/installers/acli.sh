#!/bin/bash
set -e

APP_NAME="Atlassian CLI"

# 1. Check if already installed
if command -v acli >/dev/null 2>&1; then
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
brew tap atlassian/homebrew-acli
brew install --quiet acli

# 4. Verify
if command -v acli >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
