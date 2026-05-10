#!/bin/bash
set -e

APP_NAME="npm Global Packages"

# 1. Check dependencies
if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm not available. Skipping $APP_NAME installation."
    exit 0
fi

echo "Installing $APP_NAME..."

# Update npm to latest
echo "Updating npm..."
sudo npm install --global --silent npm

# Install npm-check-updates
if ! command -v ncu >/dev/null 2>&1; then
    echo "Installing npm-check-updates..."
    sudo npm install --global --silent npm-check-updates
fi

echo "$APP_NAME installed successfully."
