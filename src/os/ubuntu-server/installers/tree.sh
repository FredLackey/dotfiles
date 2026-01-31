#!/bin/bash
set -e

APP_NAME="Tree"

# 1. Check if already installed
if command -v tree >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo apt-get install -y -qq tree

# 3. Verify
if command -v tree >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
