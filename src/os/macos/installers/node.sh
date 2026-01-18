#!/bin/bash
set -e

APP_NAME="Node.js (LTS via NVM)"

# 1. Load NVM
export NVM_DIR="$HOME/.nvm"
BREW_PREFIX=$(brew --prefix)

# Try to load nvm from brew location
if [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
    . "$BREW_PREFIX/opt/nvm/nvm.sh"
elif [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo "Error: NVM not found. Please install NVM first."
    exit 1
fi

echo "Installing $APP_NAME..."

# 2. Install LTS
nvm install --lts

# 3. Set Default
nvm alias default 'lts/*'
nvm use default

if command -v node >/dev/null; then
    NODE_VERSION=$(node -v)
    echo "$APP_NAME installed successfully ($NODE_VERSION)."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
