#!/bin/bash
set -e

APP_NAME="Web Font Tools"

# 1. Check if already installed
if command -v brew >/dev/null && brew list woff2 &>/dev/null; then
    echo "$APP_NAME are already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
brew tap bramstein/webfonttools
brew install --quiet sfnt2woff-zopfli
brew install --quiet sfnt2woff
brew install --quiet woff2

# 4. Verify
if brew list woff2 &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
