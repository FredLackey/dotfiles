#!/bin/bash
set -e

APP_NAME="AWS CLI"

# 1. Check if already installed
if command -v aws >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed."
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "Installing unzip..."
    sudo apt-get install -y -qq unzip
fi

# 3. Install (using official AWS installer for latest version)
echo "Installing $APP_NAME..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install

cd - >/dev/null
rm -rf "$TEMP_DIR"

# 4. Verify
if command -v aws >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
