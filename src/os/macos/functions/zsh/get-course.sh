#!/bin/zsh
# get-course - Download a Pluralsight course using yt-dlp
#
# Usage:
#   get-course course-name-from-url username password
#
# Dependencies:
#   - yt-dlp (brew install yt-dlp)

get-course() {
    local usage="get-course <course-name> <username> <password>"
    local course="$1"
    local username="$2"
    local password="$3"

    # Check if yt-dlp is installed
    if ! command -v yt-dlp &> /dev/null; then
        echo "Error: yt-dlp is required but not installed."
        echo "Install with: brew install yt-dlp"
        return 1
    fi

    if [ -z "$course" ]; then
        echo "Problem getting Pluralsight course: Course name not supplied"
        echo "Usage: $usage"
        return 1
    fi

    if [ -z "$username" ]; then
        echo "Problem getting Pluralsight course: Username not supplied"
        echo "Usage: $usage"
        return 1
    fi

    if [ -z "$password" ]; then
        echo "Problem getting Pluralsight course: Password not supplied"
        echo "Usage: $usage"
        return 1
    fi

    yt-dlp --verbose \
        --username "$username" \
        --password "$password" \
        --rate-limit 50K \
        --sleep-interval 600 \
        -o "%(autonumber)s - %(title)s.%(ext)s" \
        "https://app.pluralsight.com/library/courses/${course}"
}
