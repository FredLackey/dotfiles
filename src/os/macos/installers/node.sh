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
NPM_GLOBAL_PREFIX="$HOME/.local"

# The official Node.js macOS pkg always installs here. Resolve binaries from
# this path first so version managers (nvm, fnm, asdf) earlier in PATH cannot
# shadow the system install and make the version checks report the wrong node.
NODE_PKG_BIN="/usr/local/bin"

get_node_bin() {
    if [ -x "$NODE_PKG_BIN/node" ]; then
        echo "$NODE_PKG_BIN/node"
        return 0
    fi

    command -v node 2>/dev/null
}

get_npm_bin() {
    if [ -x "$NODE_PKG_BIN/npm" ]; then
        echo "$NODE_PKG_BIN/npm"
        return 0
    fi

    command -v npm 2>/dev/null
}

get_installed_node_major_version() {
    local node_bin
    node_bin="$(get_node_bin)"

    if [ -z "$node_bin" ]; then
        return 1
    fi

    "$node_bin" --version | sed -E 's/^v([0-9]+).*/\1/'
}

configure_npm_global_prefix() {
    local npm_bin
    npm_bin="$(get_npm_bin)"

    mkdir -p "$NPM_GLOBAL_PREFIX/bin"
    "$npm_bin" config set prefix "$NPM_GLOBAL_PREFIX" >/dev/null
    export PATH="$NPM_GLOBAL_PREFIX/bin:$PATH"

    CONFIGURED_PREFIX="$("$npm_bin" config get prefix)"
    if [ "$CONFIGURED_PREFIX" != "$NPM_GLOBAL_PREFIX" ]; then
        echo "Error: npm global prefix is $CONFIGURED_PREFIX, expected $NPM_GLOBAL_PREFIX."
        exit 1
    fi
}

warn_if_shadowed() {
    local path_node
    path_node="$(command -v node 2>/dev/null || true)"

    if [ -x "$NODE_PKG_BIN/node" ] && [ -n "$path_node" ] && [ "$path_node" != "$NODE_PKG_BIN/node" ]; then
        echo "Warning: '$path_node' takes precedence over '$NODE_PKG_BIN/node' in your PATH."
        echo "Warning: A version manager (e.g. nvm) is likely active; 'node' in new shells may not be v$NODE_MAJOR_VERSION."
    fi
}

# 1. Check if already installed
INSTALLED_NODE_MAJOR_VERSION="$(get_installed_node_major_version || true)"
if [ "$INSTALLED_NODE_MAJOR_VERSION" = "$NODE_MAJOR_VERSION" ] && [ -n "$(get_npm_bin)" ]; then
    configure_npm_global_prefix
    echo "$APP_NAME is already installed ($("$(get_node_bin)" --version))."
    warn_if_shadowed
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
if [ "$INSTALLED_NODE_MAJOR_VERSION" = "$NODE_MAJOR_VERSION" ] && [ -n "$(get_npm_bin)" ]; then
    configure_npm_global_prefix
    NODE_VERSION="$("$(get_node_bin)" --version)"
    echo "$APP_NAME installed successfully ($NODE_VERSION)."
    warn_if_shadowed
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
