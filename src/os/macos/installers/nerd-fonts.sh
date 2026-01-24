#!/bin/bash
set -e

APP_NAME="Nerd Fonts"

# 1. Check if already installed
if command -v brew >/dev/null && brew list font-fira-code-nerd-font &>/dev/null; then
    echo "$APP_NAME are already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
brew install --quiet font-fira-code-nerd-font
brew install --quiet font-jetbrains-mono-nerd-font

# 4. Verify
if brew list font-fira-code-nerd-font &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
