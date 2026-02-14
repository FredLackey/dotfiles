#!/bin/bash
set -e

APP_NAME="betamax"
BETAMAX_DIR="$HOME/code/betamax"

# 1. Check if already installed
if [ -d "$BETAMAX_DIR" ] && [ -f "$BETAMAX_DIR/betamax" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required to install $APP_NAME."
    exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
mkdir -p "$HOME/code"
git clone git@github.com:marcus/betamax.git "$BETAMAX_DIR"

# 4. Verify
if [ -f "$BETAMAX_DIR/betamax" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
