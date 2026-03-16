#!/bin/bash
set -e

APP_NAME="cURL"

# 1. Check if already installed
if command -v curl >/dev/null 2>&1 && dpkg -l curl 2>/dev/null | grep -q "^ii"; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq curl

# 3. Verify
if command -v curl >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
