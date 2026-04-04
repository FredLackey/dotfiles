#!/bin/bash
set -e

APP_NAME="Kiro CLI"

# 1. CHECK - Skip if already installed
if command -v kiro-cli >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi
if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: unzip is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Official installer with non-interactive flag
echo "Installing $APP_NAME..."
curl -fsSL https://cli.kiro.dev/install | bash

# 4. VERIFY - Confirm installation succeeded
# The installer places the binary in ~/.local/bin which may not be in PATH yet
export PATH="$HOME/.local/bin:$PATH"
if command -v kiro-cli >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
