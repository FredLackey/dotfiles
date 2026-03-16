#!/bin/bash
# Download a Pluralsight course using yt-dlp.
#
# Usage:
#   get-course course-name-from-url username password

get-course() {
    local usage="get-course %COURSE_NAME_FROM_URL% %USERNAME% %PASSWORD%"
    local course="$1"
    local username="$2"
    local password="$3"
    local prefix=""

    if [ -e "/usr/local/bin/yt-dlp" ]; then
        prefix="/usr/local/bin/"
    fi

    if [ -z "$course" ]; then
        echo "Problem getting Pluralsight course: Course name not supplied"
        echo "$usage"
        return 1
    elif [ -z "$username" ]; then
        echo "Problem getting Pluralsight course: Username not supplied"
        echo "$usage"
        return 1
    elif [ -z "$password" ]; then
        echo "Problem getting Pluralsight course: Password not supplied"
        echo "$usage"
        return 1
    fi

    ${prefix}yt-dlp --verbose --username "$username" --password "$password" --rate-limit 50K --sleep-interval 600 -o "%(autonumber)s - %(title)s.%(ext)s" "https://app.pluralsight.com/library/courses/${course}"
}
