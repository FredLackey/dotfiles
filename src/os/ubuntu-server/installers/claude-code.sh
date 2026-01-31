#!/bin/bash
set -e

APP_NAME="Claude Code"

# 1. Check if already installed
if command -v claude >/dev/null 2>&1; then
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
curl -fsSL https://claude.ai/install.sh | bash

# 4. Verify
# Check file existence since PATH may not be updated in current session
if [ -f "$HOME/.local/bin/claude" ] || command -v claude >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
