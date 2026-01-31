#!/bin/bash
# Resize image.
#
# Create a new image based on the specified image resized by the
# specified amount.
#
# $1: Path to the original image.
# $2: Resize value (default is 50%).
#
# Usage:
#   resize-image ./path/to/image.jpg 30%
#   resize-image ./path/to/image.jpg 1000x1000!

resize-image() {
    # Check if ImageMagick's convert command-line tool is installed.
    if ! command -v convert &>/dev/null; then
        printf "ImageMagick's 'convert' command-line tool is not installed!"
        return 1
    fi

    local path="$(dirname "$1")"
    local fileName="$(basename "$1")"
    local geometry="${2:-50%}"

    convert \
        "$1" \
        -colorspace RGB \
        +sigmoidal-contrast 11.6933 \
        -define filter:filter=Sinc \
        -define filter:window=Jinc \
        -define filter:lobes=3 \
        -sigmoidal-contrast 11.6933 \
        -colorspace sRGB \
        -background transparent \
        -gravity center \
        -resize "$geometry" \
        +append \
        "$path/_$fileName" \
    && printf "* %s (%s)\n" \
            "$path/_$fileName" \
            "$geometry"
}
