#!/bin/bash
set -e

APP_NAME="Certbot"

# 1. Check if already installed
if command -v certbot >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install via snap (recommended method for latest version)
echo "Installing $APP_NAME..."

# Ensure snapd is installed
if ! command -v snap >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq snapd
fi

# Install certbot via snap
sudo snap install --classic certbot

# Create symlink if it doesn't exist
if [ ! -f /usr/bin/certbot ]; then
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot
fi

# 3. Verify
if command -v certbot >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
