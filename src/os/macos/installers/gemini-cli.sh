#!/bin/bash
set -e

APP_NAME="Gemini CLI"

if command -v gemini >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

if ! command -v npm >/dev/null; then
    echo "Error: npm is required to install $APP_NAME."
    exit 1
fi

echo "Installing $APP_NAME..."
npm install -g @google/gemini-cli

if command -v gemini >/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
