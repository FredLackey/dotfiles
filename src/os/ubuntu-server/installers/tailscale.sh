#!/bin/bash
set -e

APP_NAME="Tailscale"

# 1. Check if already installed
if command -v tailscale >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
curl -fsSL https://tailscale.com/install.sh | sh

# 4. Verify
if command -v tailscale >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
    echo "Run 'sudo tailscale up' to connect to your tailnet."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
