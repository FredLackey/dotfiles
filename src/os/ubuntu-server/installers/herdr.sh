#!/bin/bash
set -e

APP_NAME="Herdr"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/herdr"

# 1. CHECK - Skip if already installed
# Check both PATH and the known install location because ~/.local/bin may not
# be in PATH during the installer session (shell config is not sourced yet).
if command -v herdr >/dev/null 2>&1 || [ -x "$INSTALL_PATH" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

if ! command -v awk >/dev/null 2>&1; then
    echo "Error: awk is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Official installer
echo "Installing $APP_NAME..."
HERDR_INSTALL_DIR="$INSTALL_DIR" sh -c "$(curl -fsSL https://herdr.dev/install.sh)"

# 4. VERIFY - Confirm installation succeeded
if [ -x "$INSTALL_PATH" ] || command -v herdr >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
