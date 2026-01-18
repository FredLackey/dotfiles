#!/bin/bash
set -e

APP_NAME="Git"

if command -v git >/dev/null && [[ "$(git --version)" == *"git version"* ]]; then
    # Git is usually preinstalled/xcode, so we might want to ensure brew git is used if desired.
    # But usually just "git installed" is enough idempotency.
    # However, user wants "install scripts".
    if brew list git &>/dev/null; then
         echo "$APP_NAME (Homebrew) is already installed."
         exit 0
    fi
fi

if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
brew install --quiet git

if brew list git &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
