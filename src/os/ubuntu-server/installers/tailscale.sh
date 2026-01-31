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

# 3. Check if Tailscale repository is reachable
if ! curl -fsSL --connect-timeout 5 https://pkgs.tailscale.com/ >/dev/null 2>&1; then
    echo "Warning: Cannot reach Tailscale repository. Skipping installation."
    echo "This is expected in restricted network environments."
    exit 0
fi

# 4. Install
echo "Installing $APP_NAME..."
if ! curl -fsSL https://tailscale.com/install.sh | sh; then
    echo "Warning: $APP_NAME installation failed (likely upstream issue). Skipping."
    exit 0
fi

# 5. Verify
if command -v tailscale >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
    echo "Run 'sudo tailscale up' to connect to your tailnet."
else
    echo "Warning: $APP_NAME installation did not complete successfully. Skipping."
    exit 0
fi
