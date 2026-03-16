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

# Attempt installation, but handle upstream issues gracefully
# Note: The upstream project has been known to have go.mod issues
if go install "$GITEGO_REPO" 2>&1; then
    # 4. Verify successful installation
    if [ -f "$GOPATH/bin/gitego" ]; then
        echo "$APP_NAME installed successfully."
        exit 0
    fi
fi

# Installation failed - this is often due to upstream go.mod issues
# Exit with success to allow setup to continue with other installers
echo "Warning: $APP_NAME installation failed (likely upstream issue). Skipping."
echo "This is a known issue with the upstream project's go.mod file."
echo "You may install manually later if needed: go install $GITEGO_REPO"
exit 0
