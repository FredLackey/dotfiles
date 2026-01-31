#!/bin/bash
set -e

APP_NAME="Go"

# 1. Check if already installed
if command -v go >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo apt-get install -y -qq golang-go

# Also install pinentry-tty for GPG signing in terminal
if ! dpkg -l | grep -q "^ii  pinentry-tty "; then
    echo "Installing pinentry-tty for GPG signing..."
    sudo apt-get install -y -qq pinentry-tty
fi

# 3. Verify
if command -v go >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
