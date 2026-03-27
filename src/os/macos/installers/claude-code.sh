#!/bin/bash
set -e

APP_NAME="Claude Code"

# 1. CHECK - Skip if already installed
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.claude/bin/claude" ]; then
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

# 4. ADD TO PATH - Installer drops binary in ~/.claude/bin which may not be on PATH yet
if ! command -v claude >/dev/null 2>&1 && [ -x "$HOME/.claude/bin/claude" ]; then
    export PATH="$HOME/.claude/bin:$PATH"
fi

# 5. VERIFY - Confirm installation succeeded
if command -v claude >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
