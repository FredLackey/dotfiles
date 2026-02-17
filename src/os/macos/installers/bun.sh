#!/bin/bash
set -e

APP_NAME="Bun"

if command -v bun >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

echo "Installing $APP_NAME..."
curl -fsSL https://bun.sh/install | bash

# Load bun into current shell
if [ -s "$HOME/.bun/bin/bun" ]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

if command -v bun >/dev/null; then
    echo "$APP_NAME installed successfully ($(bun --version))."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
