#!/bin/bash
set -e

APP_NAME="sidecar"
SIDECAR_REPO="github.com/marcus/sidecar/cmd/sidecar@latest"

# 1. Check if already installed
if command -v sidecar >/dev/null 2>&1; then
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
# Note: The upstream project may have go.mod version requirements that exceed
# the system Go version installed via apt on Ubuntu 22.04
if go install "$SIDECAR_REPO" 2>&1; then
    # 4. Verify successful installation
    if command -v sidecar >/dev/null 2>&1 || [ -f "$GOPATH/bin/sidecar" ]; then
        echo "$APP_NAME installed successfully."
        exit 0
    fi
fi

# Installation failed - often due to upstream go.mod version mismatch
# Exit with success to allow setup to continue with other installers
echo "Warning: $APP_NAME installation failed (likely upstream go.mod version mismatch). Skipping."
echo "This may be resolved by installing a newer version of Go."
echo "You may install manually later: go install $SIDECAR_REPO"
exit 0
