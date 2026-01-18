#!/bin/bash
set -e

APP_NAME="Xcode"
APP_PATH="/Applications/Xcode.app"

# Check if installed
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# Check dependencies
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# Prepare environment (Install xcodes)
if ! command -v xcodes >/dev/null; then
    echo "Installing xcodes and aria2..."
    brew install --quiet xcodesorg/made/xcodes aria2
fi

# Install
echo "Installing $APP_NAME (Check terminal for prompts)..."
# This might require interaction or env vars (XCODES_USERNAME/PASSWORD)
xcodes install --latest

# Verify
if [ -d "$APP_PATH" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
