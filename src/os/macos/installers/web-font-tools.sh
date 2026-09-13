#!/bin/bash
set -e

APP_NAME="Web Font Tools"

has_fonttools() {
    command -v fonttools >/dev/null 2>&1 &&
        command -v pyftsubset >/dev/null 2>&1 &&
        command -v ttx >/dev/null 2>&1
}

has_woff2_tools() {
    command -v woff2_compress >/dev/null 2>&1 &&
        command -v woff2_decompress >/dev/null 2>&1
}

# 1. Check if already installed
if has_fonttools && has_woff2_tools; then
    echo "$APP_NAME are already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# The former bramstein/webfonttools packages no longer load or compile on
# current macOS. Homebrew/core's maintained packages provide WOFF1 and WOFF2
# conversion without relying on the obsolete tap or the local C linker.
if ! has_fonttools; then
    brew install --quiet fonttools
fi

if ! has_woff2_tools; then
    brew install --quiet woff2
fi

# 4. Verify
if has_fonttools && has_woff2_tools; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
