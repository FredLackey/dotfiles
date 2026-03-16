#!/bin/bash
set -e

APP_NAME="Terraform (via TFEnv)"
TFENV_ROOT="$HOME/.tfenv"

# 1. Check if tfenv is available
if [ ! -f "$TFENV_ROOT/bin/tfenv" ]; then
    echo "Error: TFEnv is required to install Terraform."
    echo "Please ensure tfenv.sh runs before this script."
    exit 1
fi

# Add tfenv to PATH for this session
export PATH="$TFENV_ROOT/bin:$PATH"

# 2. Install
echo "Installing latest $APP_NAME..."

# Install latest stable version
tfenv install latest

# Set as global default
tfenv use latest

# 3. Verify
if command -v terraform >/dev/null 2>&1; then
    TF_VERSION=$(terraform --version | head -n 1)
    echo "$APP_NAME installed and set to default ($TF_VERSION)."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
