#!/bin/bash
set -e

APP_NAME="Bash Completion"

# 1. Check if already installed
if dpkg -s bash-completion >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq bash-completion

# 3. Verify
if dpkg -s bash-completion >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
