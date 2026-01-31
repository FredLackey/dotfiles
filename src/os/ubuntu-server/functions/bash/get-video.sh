#!/bin/bash
# Download video from a URL using yt-dlp.
#
# Usage:
#   get-video https://www.youtube.com/watch?v=video_id

get-video() {
    local usage="get-video %VIDEO_URL%"
    local url="$1"
    local prefix=""

    if [ -f "/usr/local/bin/yt-dlp" ]; then
        prefix="/usr/local/bin/"
    fi

    if [ -z "${url}" ]; then
        echo "Problem fetching video: URL not supplied"
        echo "$usage"
        return 1
    fi

    echo "Downloading video..."
    ${prefix}yt-dlp --buffer-size 16K --keep-video --prefer-insecure --format mp4 --ignore-errors --output '%(title)s.%(ext)s' "$url"
}
