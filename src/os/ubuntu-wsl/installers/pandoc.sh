#!/bin/bash
set -e

APP_NAME="Pandoc"

# 1. Check if already installed
if command -v pandoc >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq pandoc

# Also install LaTeX for PDF generation
if ! dpkg -l | grep -q "^ii  texlive-latex-recommended "; then
    echo "Installing LaTeX support..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq texlive-latex-recommended
fi

# 3. Verify
if command -v pandoc >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
