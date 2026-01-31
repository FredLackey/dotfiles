#!/bin/bash
set -e

APP_NAME="Gitego"
GITEGO_REPO="github.com/bgreenwell/gitego@main"

# 1. Check if already installed
if command -v gitego >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v go >/dev/null 2>&1; then
    echo "Warning: Go is required to install $APP_NAME. Skipping."
    exit 0
fi

# 3. Install
echo "Installing $APP_NAME..."

# Ensure GOPATH/bin is set
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

go install "$GITEGO_REPO"

# 4. Verify
if [ -f "$GOPATH/bin/gitego" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
