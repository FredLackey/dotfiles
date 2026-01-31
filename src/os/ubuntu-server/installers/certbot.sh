#!/bin/bash
set -e

APP_NAME="Certbot"

# 1. Check if already installed
if command -v certbot >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check if systemd is available (required for snapd)
if ! command -v systemctl >/dev/null 2>&1 || ! systemctl is-system-running >/dev/null 2>&1; then
    echo "Warning: $APP_NAME requires systemd/snapd which is not available."
    echo "This is expected in Docker containers and some virtualized environments."
    echo "On systems with systemd, certbot will install correctly."
    echo "Skipping $APP_NAME installation."
    exit 0
fi

# 3. Install via snap (recommended method for latest version)
echo "Installing $APP_NAME..."

# Ensure snapd is installed
if ! command -v snap >/dev/null 2>&1; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq snapd
fi

# Verify snapd daemon is accessible
if ! snap version >/dev/null 2>&1; then
    echo "Warning: snapd is installed but daemon is not accessible."
    echo "This is expected in environments without systemd."
    echo "Skipping $APP_NAME installation."
    exit 0
fi

# Install certbot via snap
sudo snap install --classic certbot

# Create symlink if it doesn't exist
if [ ! -f /usr/bin/certbot ]; then
    sudo ln -sf /snap/bin/certbot /usr/bin/certbot
fi

# 4. Verify
if command -v certbot >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
