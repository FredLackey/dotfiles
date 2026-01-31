#!/bin/bash
set -e

APP_NAME="yt-dlp"

# 1. Check if already installed
if command -v yt-dlp >/dev/null 2>&1 || [ -f "/usr/local/bin/yt-dlp" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required but not installed."
    exit 1
fi

# 3. Install (using official release for latest version)
echo "Installing $APP_NAME..."
sudo curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

# Install ffmpeg for audio extraction support
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Installing ffmpeg for audio extraction support..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ffmpeg
fi

# 4. Verify
if command -v yt-dlp >/dev/null 2>&1 || [ -f "/usr/local/bin/yt-dlp" ]; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
