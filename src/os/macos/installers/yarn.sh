#!/bin/bash
set -e

APP_NAME="Yarn"

if command -v yarn >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v npm >/dev/null; then
    echo "Error: npm is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
npm install -g yarn

if command -v yarn >/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
