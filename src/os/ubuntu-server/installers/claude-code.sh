#!/bin/bash
set -e

APP_NAME="Claude Code"

# 1. CHECK - Skip if already installed
# Check both PATH and the known install location because ~/.local/bin may not
# be in PATH during the installer session (shell config is not sourced yet).
if command -v claude >/dev/null 2>&1 || [ -f "$HOME/.local/bin/claude" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# 3. INSTALL - Native installer (auto-updates in background)
echo "Installing $APP_NAME..."
curl -fsSL https://claude.ai/install.sh | bash

# 4. VERIFY - Confirm installation succeeded
# The installer places the binary in ~/.local/bin which may not be in PATH yet
# during this session. Check the known file location as the primary check.
if [ -f "$HOME/.local/bin/claude" ] || command -v claude >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
