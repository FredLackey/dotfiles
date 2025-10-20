#!/bin/bash

# CI/CD Setup Script
#
# This script downloads and runs setup.sh with the -y flag (non-interactive mode).
# Suitable for automated deployments, containers, and CI/CD pipelines.
#
# Usage:
#   Remote: bash -c "$(wget -qO - https://raw.githubusercontent.com/fredlackey/dotfiles/main/src/os/setup-cicd.sh)"
#   Remote: bash -c "$(curl -fsSL https://raw.githubusercontent.com/fredlackey/dotfiles/main/src/os/setup-cicd.sh)"
#
# Or use the setup.sh script directly:
#   bash -c "$(wget -qO - https://raw.githubusercontent.com/fredlackey/dotfiles/main/src/os/setup.sh)" -s - -y
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/fredlackey/dotfiles/main/src/os/setup.sh)" -s - -y

set -e

declare -r SETUP_URL="https://raw.githubusercontent.com/fredlackey/dotfiles/main/src/os/setup.sh"

# Download and execute setup.sh with -y flag
if command -v curl &> /dev/null; then
    exec bash <(curl -fsSL "$SETUP_URL") -y
elif command -v wget &> /dev/null; then
    exec bash <(wget -qO - "$SETUP_URL") -y
else
    echo "Error: Neither curl nor wget is available"
    exit 1
fi

