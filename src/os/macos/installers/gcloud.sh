#!/bin/bash
set -e

APP_NAME="Google Cloud CLI"

# 1. Check if already installed
if command -v gcloud >/dev/null 2>&1 || (command -v brew >/dev/null 2>&1 && brew list --cask gcloud-cli &>/dev/null); then
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
brew install --cask --quiet gcloud-cli

# 4. Verify
if command -v gcloud >/dev/null 2>&1 || brew list --cask gcloud-cli &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
