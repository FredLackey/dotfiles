#!/bin/bash
set -e

APP_NAME="Build Essential"

# 1. Check if already installed
if dpkg -l | grep -q "^ii  build-essential "; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq build-essential

# Also install debian-archive-keyring for secure package verification
if ! dpkg -l | grep -q "^ii  debian-archive-keyring "; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq debian-archive-keyring
fi

# 3. Verify
if dpkg -l | grep -q "^ii  build-essential "; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
