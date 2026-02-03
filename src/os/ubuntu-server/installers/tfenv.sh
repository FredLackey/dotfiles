#!/bin/bash
set -e

APP_NAME="TFEnv"
TFENV_ROOT="$HOME/.tfenv"

# 1. Check if already installed
if command -v tfenv >/dev/null 2>&1 || [ -d "$TFENV_ROOT" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# Clone tfenv repository
git clone --depth 1 https://github.com/tfutils/tfenv.git "$TFENV_ROOT"

# Note: PATH is configured in .bash_profile (deployed by shell-config.sh)

# Add to PATH for current session
export PATH="$TFENV_ROOT/bin:$PATH"

# 4. Verify
if command -v tfenv >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
