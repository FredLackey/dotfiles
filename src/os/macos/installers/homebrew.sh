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
# Use NONINTERACTIVE=1 to avoid prompts
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Function to configure shell profile
configure_profile() {
    local shell_profile="$1"
    local brew_path="$2"
    
    if [ ! -f "$shell_profile" ]; then
        touch "$shell_profile"
    fi
    
    # Check if already configured
    if ! grep -q "shellenv" "$shell_profile"; then
        echo "Adding Homebrew to $shell_profile..."
        echo >> "$shell_profile"
        echo "eval \"\$($brew_path shellenv)\"" >> "$shell_profile"
    else
        echo "Homebrew already configured in $shell_profile."
    fi
}

# Post-install Configuration
BREW_PATH=""
if [ -f "/opt/homebrew/bin/brew" ]; then
    BREW_PATH="/opt/homebrew/bin/brew"
elif [ -f "/usr/local/bin/brew" ]; then
    BREW_PATH="/usr/local/bin/brew"
fi

if [ -n "$BREW_PATH" ]; then
    # Configure Zsh (Standard on modern macOS)
    configure_profile "$HOME/.zprofile" "$BREW_PATH"
    
    # Configure Bash (Legacy/Alternative)
    if [ -f "$HOME/.bash_profile" ]; then
        configure_profile "$HOME/.bash_profile" "$BREW_PATH"
    elif [ -f "$HOME/.bashrc" ]; then
        configure_profile "$HOME/.bashrc" "$BREW_PATH"
    fi
    
    echo "$APP_NAME installed and configured."
else
    echo "Error: $APP_NAME installation failed or cannot be found."
    exit 1
fi
