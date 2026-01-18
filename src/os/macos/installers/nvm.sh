#!/bin/bash
set -e

APP_NAME="NVM"

# NVM is a shell function, so checking "command -v nvm" might fail if not loaded.
# Check existence of NVM_DIR or brew list.
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ] || (command -v brew >/dev/null && brew list nvm &>/dev/null); then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --quiet nvm

# Create directory if it doesn't exist
mkdir -p "$HOME/.nvm"

# Determine Homebrew prefix
BREW_PREFIX=$(brew --prefix)

# Function to configure shell profile
configure_profile() {
    local shell_profile="$1"
    
    if [ ! -f "$shell_profile" ]; then
        touch "$shell_profile"
    fi
    
    # Check if already configured
    if ! grep -q "NVM_DIR" "$shell_profile"; then
        echo "Adding NVM to $shell_profile..."
        echo "" >> "$shell_profile"
        echo "# NVM Setup" >> "$shell_profile"
        echo "export NVM_DIR=\"\$HOME/.nvm\"" >> "$shell_profile"
        echo "[ -s \"$BREW_PREFIX/opt/nvm/nvm.sh\" ] && \\. \"$BREW_PREFIX/opt/nvm/nvm.sh\"  # This loads nvm" >> "$shell_profile"
        echo "[ -s \"$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm\" ] && \\. \"$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm\"  # This loads nvm bash_completion" >> "$shell_profile"
    else
        echo "NVM already configured in $shell_profile."
    fi
}

# Configure Zsh (Standard on modern macOS)
configure_profile "$HOME/.zprofile"

# Configure Bash (Legacy/Alternative)
if [ -f "$HOME/.bash_profile" ]; then
    configure_profile "$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    configure_profile "$HOME/.bashrc"
fi

if brew list nvm &>/dev/null; then
    echo "$APP_NAME installed and configured successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
