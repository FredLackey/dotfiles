#!/bin/bash
set -e

APP_NAME="Herdr"

# 1. CHECK - Skip if already installed
if command -v herdr >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Homebrew formula
echo "Installing $APP_NAME..."
brew install --quiet herdr

# 4. VERIFY - Confirm installation succeeded
if command -v herdr >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
