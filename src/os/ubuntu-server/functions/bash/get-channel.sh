#!/bin/bash
# Download videos from a YouTube channel using yt-dlp.
#
# Usage:
#   get-channel channelName

get-channel() {
    local usage="get-channel %CHANNEL_NAME%"
    local channel="$1"
    local prefix=""

    if [ -e "/usr/local/bin/yt-dlp" ]; then
        prefix="/usr/local/bin/"
    fi

    if [ -z "$channel" ]; then
        echo "Problem getting YouTube channel: Channel name not supplied"
        echo "$usage"
        return 1
    fi

    ${prefix}yt-dlp -f best -ciw -v -o "%(upload_date)s - %(title)s.%(ext)s" "https://www.youtube.com/user/$channel"
}
