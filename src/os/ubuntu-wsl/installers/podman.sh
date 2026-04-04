#!/bin/bash
set -e

APP_NAME="Podman"

# 1. Check if already installed
if command -v podman >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: apt-get is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq podman

# 4. Verify
if command -v podman >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
