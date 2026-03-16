#!/bin/bash
set -e

APP_NAME="Node.js (LTS via NVM)"
NVM_DIR="$HOME/.nvm"

# 1. Check if already installed
if command -v node >/dev/null 2>&1; then
    echo "$APP_NAME is already installed ($(node --version))."
    exit 0
fi

# 2. Check dependencies
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Error: NVM is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# Load NVM
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# Install Node LTS
nvm install --lts
nvm alias default 'lts/*'
nvm use default

# 4. Verify
if command -v node >/dev/null 2>&1; then
    echo "$APP_NAME $(node --version) installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
