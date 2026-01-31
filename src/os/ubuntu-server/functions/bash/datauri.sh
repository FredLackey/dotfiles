#!/bin/bash
# Create data URI from a file.
#
# Usage:
#   datauri image.png

datauri() {
    local mimeType=""

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
