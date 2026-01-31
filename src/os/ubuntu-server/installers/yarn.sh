#!/bin/bash
set -e

APP_NAME="Yarn"
NVM_DIR="$HOME/.nvm"

# 1. Check if already installed
if command -v yarn >/dev/null 2>&1 && dpkg -l yarn 2>/dev/null | grep -q "^ii"; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if [ ! -d "$NVM_DIR" ]; then
    echo "Error: NVM is required to install $APP_NAME."
    exit 1
fi

# 3. Install via APT
echo "Installing $APP_NAME..."

# Add Yarn GPG key
if [ ! -f /usr/share/keyrings/yarn-archive-keyring.gpg ]; then
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg
fi

# Add Yarn repository
if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
    echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null
    sudo apt-get update -qq
fi

# Install without recommends (since we use NVM for Node)
sudo apt-get install -y -qq --no-install-recommends yarn

# 4. Verify
if command -v yarn >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
