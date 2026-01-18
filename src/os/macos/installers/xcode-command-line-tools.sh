#!/bin/bash
set -e

APP_NAME="Xcode Command Line Tools"

# Check if installed
if xcode-select -p &>/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# Install
echo "Installing $APP_NAME..."

# Non-interactive installation trick
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

# Find the Command Line Tools package name
CLT_PACKAGE=$(softwareupdate -l 2>&1 | grep -o "Command Line Tools for Xcode-[0-9.]*" | head -n 1)

if [ -z "$CLT_PACKAGE" ]; then
    echo "Error: Could not find Command Line Tools package via softwareupdate."
    echo "Silent installation failed. Please install manually or check internet connection."
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    exit 1
else
    echo "Installing $CLT_PACKAGE..."
    softwareupdate -i "$CLT_PACKAGE" --verbose
fi

rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

# Verify
if xcode-select -p &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
