#!/bin/bash
set -e

APP_NAME="Terraform (via TFEnv)"

# Check if tfenv is available
if ! command -v tfenv >/dev/null; then
    echo "Error: TFEnv is required to install Terraform."
    echo "Please ensure tfenv.sh runs before this script."
    exit 1
fi

echo "Installing latest $APP_NAME..."

# Install latest stable version
tfenv install latest

# Set as global default
tfenv use latest

# Verify
if command -v terraform >/dev/null; then
    # Parse version for display
    TF_VERSION=$(terraform --version | head -n 1)
    echo "$APP_NAME installed and set to default ($TF_VERSION)."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
