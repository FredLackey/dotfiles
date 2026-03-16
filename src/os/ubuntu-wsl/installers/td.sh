#!/bin/bash
set -e

APP_NAME="td"

# 1. Check if already installed
GOBIN="$(go env GOPATH 2>/dev/null || echo "$HOME/go")/bin"
if command -v td >/dev/null 2>&1 || [ -f "$GOBIN/td" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v go >/dev/null 2>&1; then
    echo "Error: Go is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
go install github.com/marcus/td@latest

# 4. Verify
if command -v td >/dev/null 2>&1 || [ -f "$GOBIN/td" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
