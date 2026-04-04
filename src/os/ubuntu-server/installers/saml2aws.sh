#!/bin/bash
set -e

APP_NAME="saml2aws"

# 1. Check if already installed
if command -v saml2aws >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install $APP_NAME."
    exit 1
fi
if ! command -v tar >/dev/null 2>&1; then
    echo "Error: tar is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# Determine architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  S2A_ARCH="amd64" ;;
    aarch64) S2A_ARCH="arm64" ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Fetch the latest version number
CURRENT_VERSION=$(curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Failed to determine latest $APP_NAME version."
    exit 1
fi
echo "Latest version: ${CURRENT_VERSION}"

# Download and extract the tarball
TARBALL="saml2aws_${CURRENT_VERSION}_linux_${S2A_ARCH}.tar.gz"
curl -fsSL -o "/tmp/${TARBALL}" "https://github.com/Versent/saml2aws/releases/download/v${CURRENT_VERSION}/${TARBALL}"
tar -xzf "/tmp/${TARBALL}" -C /tmp saml2aws

# Install the binary
sudo install -o root -g root -m 0755 /tmp/saml2aws /usr/local/bin/saml2aws

# Clean up
rm -f "/tmp/${TARBALL}" /tmp/saml2aws

# 4. Verify
if command -v saml2aws >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
