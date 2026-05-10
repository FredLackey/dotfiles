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
curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x" | sudo -E bash -
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nodejs

# 4. Verify
INSTALLED_NODE_MAJOR_VERSION="$(get_installed_node_major_version || true)"
if [ "$INSTALLED_NODE_MAJOR_VERSION" = "$NODE_MAJOR_VERSION" ] && command -v npm >/dev/null 2>&1; then
    echo "$APP_NAME $(node --version) installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
