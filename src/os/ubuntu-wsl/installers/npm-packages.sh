#!/bin/bash
set -e

APP_NAME="npm Global Packages"
NVM_DIR="$HOME/.nvm"

# 1. Check dependencies
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Warning: NVM not found. Skipping $APP_NAME installation."
    exit 0
fi

echo "Installing $APP_NAME..."

# Load NVM
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# Verify npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm not available. Skipping $APP_NAME installation."
    exit 0
fi

# Update npm to latest
echo "Updating npm..."
npm install --global --silent npm

# Install npm-check-updates
if ! command -v ncu >/dev/null 2>&1; then
    echo "Installing npm-check-updates..."
    npm install --global --silent npm-check-updates
fi

echo "$APP_NAME installed successfully."
