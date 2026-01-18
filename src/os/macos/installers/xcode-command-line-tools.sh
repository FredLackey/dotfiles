#!/bin/bash
set -e

APP_NAME="Xcode Command Line Tools"
CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Cleanup function to remove the placeholder file
cleanup() {
    rm -f "$CLT_PLACEHOLDER"
}
trap cleanup EXIT

# Function to check if CLT is installed
# Matches logic from research/installs/xcode-clt.js
is_installed() {
    # 1. Check xcode-select path
    local developer_path
    if ! developer_path=$(xcode-select -p 2>/dev/null); then
        # xcode-select failed, but check if files exist anyway
        if [ -x "/Library/Developer/CommandLineTools/usr/bin/clang" ]; then
            return 0
        fi
        if [ -x "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" ]; then
            return 0
        fi
        return 1
    fi
    
    if [ -z "$developer_path" ]; then
        return 1
    fi

    # 2. Verify path exists
    if [ ! -d "$developer_path" ]; then
        return 1
    fi

    # 3. Verify clang exists (deep check)
    local clt_clang="$developer_path/usr/bin/clang"
    # Note: Full Xcode path might vary, simplified check here based on xcode-select result
    if [ -x "$clt_clang" ]; then
        return 0
    fi
    
    return 1
}

# Check if already installed
if is_installed; then
    echo "$APP_NAME is already installed."
    exit 0
fi

echo "Installing $APP_NAME..."

# Prepare for non-interactive install (The "Touch Trick")
touch "$CLT_PLACEHOLDER"

# Find Package Name
echo "Checking for available updates..."
# Capture output, merge stderr
UPDATES=$(softwareupdate -l 2>&1)

# Try to find the package using grep with a regex that matches the research patterns
# Research uses: (Command Line Tools for Xcode-[\d.]+)
# We use grep -oE to use extended regex for robustness
CLT_PACKAGE=$(echo "$UPDATES" | grep -oE 'Command Line Tools for Xcode-[0-9.]+' | head -n 1)

if [ -z "$CLT_PACKAGE" ]; then
    echo "Warning: Could not find Command Line Tools package in softwareupdate."
    echo "Available updates output:"
    echo "$UPDATES"
    echo ""
    echo "Possible reasons:"
    echo "1. Already installed but not detected by xcode-select."
    echo "2. macOS version incompatibility."
    echo "3. Network issues."
    echo ""
    exit 1
fi

echo "Found package: $CLT_PACKAGE"
echo "Installing... (this requires sudo)"

# Install
sudo softwareupdate -i "$CLT_PACKAGE" --verbose

# Post-install validation and fixup
if is_installed; then
    echo "$APP_NAME installed successfully."
elif [ -x "/Library/Developer/CommandLineTools/usr/bin/clang" ]; then
    echo "Files found at /Library/Developer/CommandLineTools, but xcode-select is not set."
    echo "Setting xcode-select path..."
    sudo xcode-select -s /Library/Developer/CommandLineTools
    echo "$APP_NAME configured successfully."
else
    echo "Error: $APP_NAME installation failed validation."
    exit 1
fi
