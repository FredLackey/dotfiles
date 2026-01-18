#!/bin/bash
set -e

APP_NAME="DBeaver"
APP_PATH="/Applications/DBeaver.app"

if [ -d "$APP_PATH" ] || (command -v brew >/dev/null && brew list --cask dbeaver-community &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --cask --quiet dbeaver-community

if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
