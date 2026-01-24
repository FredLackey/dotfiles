#!/bin/bash
# get-channel - Download all videos from a YouTube channel
#
# Usage:
#   get-channel channelName
#
# Dependencies:
#   - yt-dlp (brew install yt-dlp)

get-channel() {
    local usage="get-channel <channel-name>"
    local channel="$1"

    # Check if yt-dlp is installed
    if ! command -v yt-dlp &> /dev/null; then
        echo "Error: yt-dlp is required but not installed."
        echo "Install with: brew install yt-dlp"
        return 1
    fi

    if [ -z "$channel" ]; then
        echo "Problem getting YouTube channel: Channel name not supplied"
        echo "Usage: $usage"
        return 1
    fi

    yt-dlp -f best -ciw -v \
        -o "%(upload_date)s - %(title)s.%(ext)s" \
        "https://www.youtube.com/user/$channel"
}
