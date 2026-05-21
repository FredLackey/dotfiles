#!/bin/bash
set -e

APP_NAME="Homebrew"

get_brew_path() {
    if command -v brew >/dev/null 2>&1; then
        command -v brew
        return 0
    fi

    if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "/opt/homebrew/bin/brew"
        return 0
    fi

    if [ -x "/usr/local/bin/brew" ]; then
        echo "/usr/local/bin/brew"
        return 0
    fi

    return 1
}

# 1. Check if already installed
BREW_PATH="$(get_brew_path || true)"
if [ -n "$BREW_PATH" ]; then
    echo "$APP_NAME is already installed at $BREW_PATH."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Verify
BREW_PATH="$(get_brew_path || true)"
if [ -n "$BREW_PATH" ]; then
    echo "$APP_NAME installed successfully at $BREW_PATH."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi

# Note: Shell configuration (PATH setup) is handled by dotfiles shell config files.
# See: src/os/macos/files/.zshrc and src/os/macos/files/.bash_profile
