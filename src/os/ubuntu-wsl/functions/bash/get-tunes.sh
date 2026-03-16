#!/bin/bash
# Download audio or video from a URL using yt-dlp.
#
# Usage:
#   get-tunes https://www.youtube.com/watch?v=video_id audio-only
#   get-tunes https://www.youtube.com/playlist?list=playlist_id

get-tunes() {
    local usage="get-tunes %PLAYLIST_OR_VIDEO_URL% [audio-only | video-only]"
    local url="$1"
    local option="$2"
    local prefix=""

    if [ -f "/usr/local/bin/yt-dlp" ]; then
        prefix="/usr/local/bin/"
    fi

    if [ -z "${url}" ]; then
        echo "Problem fetching track: Track URL not supplied"
        echo "$usage"
        return 1
    elif [ -z "${option}" ]; then
        echo "Fetching audio & video..."
        ${prefix}yt-dlp --buffer-size 16K --keep-video --audio-format mp3 --extract-audio --embed-thumbnail --prefer-insecure --format mp4 --ignore-errors --output '%(title)s.%(ext)s' "$url"
    elif [[ "$option" == "audio-only" ]]; then
        echo "Excluding video..."
        ${prefix}yt-dlp --buffer-size 16K --audio-format mp3 --extract-audio --embed-thumbnail --prefer-insecure --ignore-errors --output '%(title)s.%(ext)s' "$url"
    elif [[ "$option" == "video-only" ]]; then
        echo "Excluding audio..."
        ${prefix}yt-dlp --buffer-size 16K --keep-video --prefer-insecure --format mp4 --ignore-errors --output '%(title)s.%(ext)s' "$url"
    else
        echo "Problem fetching track: Unknown option supplied ($option)"
        echo "$usage"
        return 1
    fi
}
