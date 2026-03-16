#!/bin/bash
set -e

APP_NAME="APT Cleanup"

echo "Running $APP_NAME..."

# Remove packages that are no longer needed
sudo apt-get autoremove -y -qq

# Clean package cache
sudo apt-get clean -qq

echo "$APP_NAME completed."
