#!/bin/bash
set -e

APP_NAME="Git"

# 1. Check if already installed
if command -v git >/dev/null 2>&1 && dpkg -l git 2>/dev/null | grep -q "^ii"; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo apt-get install -y -qq git

# 3. Verify
if command -v git >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
