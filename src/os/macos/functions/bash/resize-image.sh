#!/bin/bash
# resize-image - Resize an image using ImageMagick
#
# Creates a new image with the specified resize value using high-quality resampling.
#
# Usage:
#   resize-image ./path/to/image.jpg 30%
#   resize-image ./path/to/image.jpg 1000x1000!
#
# Dependencies:
#   - ImageMagick (brew install imagemagick)

resize-image() {
    # Check if ImageMagick's convert command is installed
    if ! command -v convert &> /dev/null; then
        echo "Error: ImageMagick's 'convert' command is not installed."
        echo "Install with: brew install imagemagick"
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: resize-image <image-path> [geometry]"
        echo "Example: resize-image ./image.jpg 50%"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File not found: $1"
        return 1
    fi

    local path
    local fileName
    local geometry

    path="$(dirname "$1")"
    fileName="$(basename "$1")"
    geometry="${2:-50%}"

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
