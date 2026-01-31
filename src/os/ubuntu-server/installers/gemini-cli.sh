#!/bin/bash
set -e

APP_NAME="Gemini CLI"
NVM_DIR="$HOME/.nvm"

# 1. Check if already installed
if command -v gemini >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Warning: NVM not found. Skipping $APP_NAME installation."
    exit 0
fi

# Load NVM
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm not available. Skipping $APP_NAME installation."
    exit 0
fi

# 3. Install
echo "Installing $APP_NAME..."
npm install --global --silent @google/gemini-cli

# 4. Verify
if command -v gemini >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
