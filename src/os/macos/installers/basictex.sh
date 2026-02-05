#!/bin/bash
set -e

APP_NAME="BasicTeX"
TEX_BIN_DIR="/Library/TeX/texbin"

if [ -d "$TEX_BIN_DIR" ] || (command -v brew >/dev/null && brew list --cask basictex &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --cask --quiet basictex

if [ -d "$TEX_BIN_DIR" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
