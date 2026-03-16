#!/bin/bash
set -e

APP_NAME="APT Update"

echo "Updating package lists..."
sudo apt-get update -qq >/dev/null

echo "Upgrading installed packages..."
sudo apt-get upgrade -y -qq >/dev/null

echo "$APP_NAME completed."
