#!/bin/bash
set -e

APP_NAME="OpenCode CLI"

# 1. CHECK - Skip if already installed
if command -v opencode >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Official npm package
echo "Installing $APP_NAME..."
npm install -g opencode-ai

# 4. VERIFY - Confirm installation succeeded
if command -v opencode >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
