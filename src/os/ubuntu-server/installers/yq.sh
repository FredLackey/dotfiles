#!/bin/bash
set -e

APP_NAME="yq"

# 1. Check if already installed
if command -v yq >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v wget >/dev/null 2>&1; then
    echo "Error: wget is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# Determine architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  YQ_ARCH="amd64" ;;
    aarch64) YQ_ARCH="arm64" ;;
    armv7l)  YQ_ARCH="arm" ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Download and install latest yq binary
YQ_VERSION=$(wget -qO- https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
wget -qO /tmp/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${YQ_ARCH}"
sudo install -o root -g root -m 0755 /tmp/yq /usr/local/bin/yq
rm -f /tmp/yq

# 4. Verify
if command -v yq >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
