#!/bin/bash
set -e

APP_NAME="APT Update"

echo "Updating package lists..."
sudo apt-get update -qq

echo "Upgrading installed packages..."
sudo apt-get upgrade -y -qq

echo "$APP_NAME completed."
