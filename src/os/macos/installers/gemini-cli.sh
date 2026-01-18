#!/bin/bash
set -e

APP_NAME="Gemini CLI"

if (command -v brew >/dev/null && brew list gemini-cli &>/dev/null) || command -v gemini >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --quiet gemini-cli

if brew list gemini-cli &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
