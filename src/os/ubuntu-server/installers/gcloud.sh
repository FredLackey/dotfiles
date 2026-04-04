#!/bin/bash
set -e

APP_NAME="Google Cloud CLI"

# 1. Check if already installed
if command -v gcloud >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
for dep in curl gpg; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Error: $dep is required to install $APP_NAME."
        exit 1
    fi
done

# 3. Install via official Google Cloud apt repository
echo "Installing $APP_NAME..."

# Create keyring directory
sudo mkdir -p -m 755 /etc/apt/keyrings

# Download and dearmor the GPG key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/cloud.google.gpg
sudo chmod go+r /etc/apt/keyrings/cloud.google.gpg

# Add the repository
sudo mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [signed-by=/etc/apt/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list >/dev/null

# Update and install
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq google-cloud-cli

# 4. Verify
if command -v gcloud >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
