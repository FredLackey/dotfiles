#!/bin/zsh
# get-tunes - Download audio and/or video from a URL
#
# Usage:
#   get-tunes https://www.youtube.com/watch?v=video_id            # Both audio & video
#   get-tunes https://www.youtube.com/watch?v=video_id audio-only # Audio only (MP3)
#   get-tunes https://www.youtube.com/watch?v=video_id video-only # Video only (MP4)
#   get-tunes https://www.youtube.com/playlist?list=playlist_id   # Full playlist
#
# Dependencies:
#   - yt-dlp (brew install yt-dlp)

get-tunes() {
    local usage="get-tunes <url> [audio-only | video-only]"
    local url="$1"
    local option="$2"

    # Check if yt-dlp is installed
    if ! command -v yt-dlp &> /dev/null; then
        echo "Error: yt-dlp is required but not installed."
        echo "Install with: brew install yt-dlp"
        return 1
    fi

    if [ -z "$url" ]; then
        echo "Problem fetching track: Track URL not supplied"
        echo "Usage: $usage"
        return 1
    fi

    if [ -z "$option" ]; then
        echo "Fetching audio & video..."
        yt-dlp --buffer-size 16K \
            --keep-video \
            --audio-format mp3 \
            --extract-audio \
            --embed-thumbnail \
            --prefer-insecure \
            --format mp4 \
            --ignore-errors \
            --output '%(title)s.%(ext)s' \
            "$url"
    elif [ "$option" = "audio-only" ]; then
        echo "Excluding video..."
        yt-dlp --buffer-size 16K \
            --audio-format mp3 \
            --extract-audio \
            --embed-thumbnail \
            --prefer-insecure \
            --ignore-errors \
            --output '%(title)s.%(ext)s' \
            "$url"
    elif [ "$option" = "video-only" ]; then
        echo "Excluding audio..."
        yt-dlp --buffer-size 16K \
            --keep-video \
            --prefer-insecure \
            --format mp4 \
            --ignore-errors \
            --output '%(title)s.%(ext)s' \
            "$url"
    else
        echo "Problem fetching track: Unknown option supplied ($option)"
        echo "Usage: $usage"
        return 1
    fi
}
