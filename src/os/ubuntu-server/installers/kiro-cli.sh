#!/bin/bash
set -e

APP_NAME="Kiro CLI"
INSTALL_DIR="$HOME/.local/bin"
KIRO_CLI_PATH="$INSTALL_DIR/kiro-cli"
KIRO_CHAT_PATH="$INSTALL_DIR/kiro-cli-chat"

# 1. CHECK - Skip if already installed
if command -v kiro-cli >/dev/null 2>&1 || [ -x "$KIRO_CLI_PATH" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Official installer (no interactive prompts on Linux)
echo "Installing $APP_NAME..."
if [ -e "$KIRO_CLI_PATH" ]; then
    echo "Removing incomplete $APP_NAME installation..."
    rm -f "$KIRO_CLI_PATH" "$KIRO_CHAT_PATH"
fi
curl -fsSL https://cli.kiro.dev/install | bash

# 4. VERIFY - Confirm installation succeeded
# The installer places the binary in ~/.local/bin which may not be in PATH yet
export PATH="$INSTALL_DIR:$PATH"
if command -v kiro-cli >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
