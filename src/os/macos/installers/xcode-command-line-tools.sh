#!/bin/bash
set -e

APP_NAME="Xcode Command Line Tools"
CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Check if installed
if xcode-select -p &>/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

echo "Installing $APP_NAME..."

# Create placeholder file to make CLT available (The "Touch Trick")
touch "$CLT_PLACEHOLDER"

# Find the package name
# matching "* Label: Command Line Tools..." and extracting the package name after ": "
# We use awk to reliably get the full string including spaces
CLT_PACKAGE=$(softwareupdate -l 2>&1 | grep "Label: Command Line Tools" | head -n 1 | awk -F": " '{print $2}' | tr -d '\n')

if [ -z "$CLT_PACKAGE" ]; then
    echo "Error: Could not find Command Line Tools package in softwareupdate."
    echo "Please check internet connection or install manually using 'xcode-select --install'"
    rm -f "$CLT_PLACEHOLDER"
    exit 1
fi

echo "Found package: $CLT_PACKAGE"
echo "Installing... (this requires sudo)"

# Install
sudo softwareupdate -i "$CLT_PACKAGE" --verbose

# Cleanup
rm -f "$CLT_PLACEHOLDER"

# Verify
if xcode-select -p &>/dev/null; then
    echo "$APP_NAME installed successfully."
else
    # Fallback: Sometimes installed but path not set
    if [ -d "/Library/Developer/CommandLineTools" ]; then
         echo "Setting xcode-select path..."
         sudo xcode-select -s /Library/Developer/CommandLineTools
         echo "$APP_NAME installed and configured."
    else
         echo "Error: $APP_NAME installation failed."
         exit 1
    fi
fi
