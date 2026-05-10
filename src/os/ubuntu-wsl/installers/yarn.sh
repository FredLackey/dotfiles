#!/bin/bash
set -e

APP_NAME="Yarn"

# 1. Check if already installed
if command -v yarn >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
sudo npm install --global --silent yarn

# 4. Verify
if command -v yarn >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
