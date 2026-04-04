#!/bin/bash
set -e

APP_NAME="Atlassian CLI"

# 1. Check if already installed
if command -v acli >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v wget >/dev/null 2>&1; then
    echo "Error: wget is required to install $APP_NAME."
    exit 1
fi
if ! command -v gpg >/dev/null 2>&1; then
    echo "Error: gpg is required to install $APP_NAME."
    exit 1
fi

# 3. Install via official Atlassian apt repository
echo "Installing $APP_NAME..."

# Create keyring directory
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download and install the GPG key
wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc 2>/dev/null | sudo gpg --yes --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg
sudo chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg

# Add the repository
sudo mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/acli.list

# Update and install
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq acli

# 4. Verify
if command -v acli >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
