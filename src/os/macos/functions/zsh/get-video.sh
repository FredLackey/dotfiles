#!/bin/zsh
# get-video - Download video from a URL in MP4 format
#
# Usage:
#   get-video https://www.youtube.com/watch?v=video_id
#
# Dependencies:
#   - yt-dlp (brew install yt-dlp)

get-video() {
    local usage="get-video <url>"
    local url="$1"

    # Check if yt-dlp is installed
    if ! command -v yt-dlp &> /dev/null; then
        echo "Error: yt-dlp is required but not installed."
        echo "Install with: brew install yt-dlp"
        return 1
    fi

    if [ -z "$url" ]; then
        echo "Problem fetching video: URL not supplied"
        echo "Usage: $usage"
        return 1
    fi

    echo "Downloading video..."
    yt-dlp --buffer-size 16K \
        --keep-video \
        --prefer-insecure \
        --format mp4 \
        --ignore-errors \
        --output '%(title)s.%(ext)s' \
        "$url"
}
