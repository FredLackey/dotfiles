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

# Add to PATH in .bashrc if not already present
if ! grep -q 'tfenv/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '# TFEnv' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Add to PATH for current session
export PATH="$TFENV_ROOT/bin:$PATH"

# 4. Verify
if command -v tfenv >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
