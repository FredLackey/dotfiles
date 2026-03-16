#!/bin/bash
set -e

APP_NAME="Claude Code"

# 1. CHECK - Skip if already installed
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
curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1

# 4. VERIFY - Confirm installation succeeded
if command -v claude >/dev/null 2>&1 || [ -f "$HOME/.local/bin/claude" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
