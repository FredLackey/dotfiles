#!/bin/bash
set -e

APP_NAME="Homebrew"

# 1. Check if already installed
if command -v brew >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Verify
if [ -f "/opt/homebrew/bin/brew" ] || [ -f "/usr/local/bin/brew" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi

# Note: Shell configuration (PATH setup) is handled by dotfiles shell config files.
# See: src/os/macos/files/.zshrc and src/os/macos/files/.bash_profile
