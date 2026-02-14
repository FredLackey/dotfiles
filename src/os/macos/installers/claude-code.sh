#!/bin/bash
set -e

APP_NAME="Claude Code"

if command -v claude >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

if (command -v brew >/dev/null && brew list --cask claude-code &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --cask --quiet claude-code

if brew list --cask claude-code &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
