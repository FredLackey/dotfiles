#!/bin/bash
set -e

APP_NAME="Podman"

# 1. Check if already installed
if command -v podman >/dev/null 2>&1; then
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
brew install --quiet podman

# 4. Verify
if ! command -v podman >/dev/null 2>&1; then
    echo "Error: $APP_NAME installation failed."
    exit 1
fi

echo "$APP_NAME installed successfully."
echo "Note: Run 'podman machine init && podman machine start' to set up the Linux VM."
