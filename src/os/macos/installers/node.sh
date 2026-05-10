#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NODE_VERSION_FILE="$SCRIPT_DIR/../../../../.node-version"

if [ ! -f "$NODE_VERSION_FILE" ]; then
    echo "Error: Node version file not found at $NODE_VERSION_FILE."
    exit 1
fi

NODE_MAJOR_VERSION="$(tr -d '[:space:]' < "$NODE_VERSION_FILE")"
APP_NAME="Node.js v$NODE_MAJOR_VERSION"

get_installed_node_major_version() {
    if ! command -v node >/dev/null 2>&1; then
        return 1
    fi

    node --version | sed -E 's/^v([0-9]+).*/\1/'
}

# 1. Check if already installed
INSTALLED_NODE_MAJOR_VERSION="$(get_installed_node_major_version || true)"
if [ "$INSTALLED_NODE_MAJOR_VERSION" = "$NODE_MAJOR_VERSION" ] && command -v npm >/dev/null 2>&1; then
    echo "$APP_NAME is already installed ($(node --version))."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    echo "Error: sudo is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PACKAGE_FILE="$(curl -fsSL "https://nodejs.org/dist/latest-v${NODE_MAJOR_VERSION}.x/SHASUMS256.txt" | grep -Eo "node-v[0-9]+\.[0-9]+\.[0-9]+\.pkg" | head -n 1)"
if [ -z "$PACKAGE_FILE" ]; then
    echo "Error: Unable to resolve a macOS installer for Node.js v$NODE_MAJOR_VERSION."
    exit 1
fi

curl -fsSL "https://nodejs.org/dist/latest-v${NODE_MAJOR_VERSION}.x/$PACKAGE_FILE" -o "$TMP_DIR/$PACKAGE_FILE"
sudo installer -pkg "$TMP_DIR/$PACKAGE_FILE" -target /

# 4. Verify
INSTALLED_NODE_MAJOR_VERSION="$(get_installed_node_major_version || true)"
if [ "$INSTALLED_NODE_MAJOR_VERSION" = "$NODE_MAJOR_VERSION" ] && command -v npm >/dev/null 2>&1; then
    NODE_VERSION="$(node -v)"
    echo "$APP_NAME installed successfully ($NODE_VERSION)."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
