#!/bin/bash
set -e

APP_NAME="Python 3"

# 1. Check if already installed
if command -v python3 >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo apt-get install -y -qq python3 python3-pip python3-venv

# 3. Verify
if command -v python3 >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
