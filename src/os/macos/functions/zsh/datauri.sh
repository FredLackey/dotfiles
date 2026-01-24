#!/bin/zsh
# datauri - Create a base64 data URI from a file
#
# Usage:
#   datauri image.png
#
# Dependencies:
#   - file (pre-installed on macOS)
#   - openssl (pre-installed on macOS)

datauri() {
    local mimeType=""

    if [ -z "$1" ]; then
        echo "Usage: datauri <file>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        printf "%s is not a file.\n" "$1"
        return 1
    fi

    mimeType=$(file --brief --mime-type "$1")

    if [[ $mimeType == text/* ]]; then
        mimeType="$mimeType;charset=utf-8"
    fi

    printf "data:%s;base64,%s" \
        "$mimeType" \
        "$(openssl base64 -in "$1" | tr -d "\n")"
}
