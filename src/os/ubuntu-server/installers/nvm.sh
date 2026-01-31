#!/bin/bash
set -e

APP_NAME="NVM"
NVM_DIR="$HOME/.nvm"
NVM_GIT_REPO="https://github.com/nvm-sh/nvm.git"

# 1. Check if already installed
if [ -d "$NVM_DIR" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
git clone --quiet "$NVM_GIT_REPO" "$NVM_DIR"

# Checkout latest version
cd "$NVM_DIR"
git checkout --quiet "$(git describe --abbrev=0 --tags)"

# 4. Verify
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
