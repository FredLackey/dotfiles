#!/bin/bash
set -e

APP_NAME="Homebrew"

# Check if installed
if command -v brew >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# Check dependencies
# Homebrew needs curl and bash, which are standard on macOS
if ! command -v curl >/dev/null; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# Install
echo "Installing $APP_NAME..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify
if command -v brew >/dev/null; then
    echo "$APP_NAME installed successfully."
else
    # It might be installed but not in PATH yet
    if [ -f "/opt/homebrew/bin/brew" ]; then
         echo "$APP_NAME installed to /opt/homebrew/bin/brew. You may need to add it to your PATH."
         exit 0
    elif [ -f "/usr/local/bin/brew" ]; then
         echo "$APP_NAME installed to /usr/local/bin/brew."
         exit 0
    else
         echo "Error: $APP_NAME installation failed or cannot be found."
         exit 1
    fi
fi
