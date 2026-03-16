#!/bin/bash
# Compare files in the current directory with another, removing the smaller version of each pair.
#
# Usage:
#   remove-smaller-files /path/to/other/directory

remove-smaller-files() {
    local LEFT_DIR="$PWD"
    local RIGHT_DIR="$*"
    echo "LEFT : $LEFT_DIR"
    echo "RIGHT: $RIGHT_DIR"
    local files="$(find -L "$LEFT_DIR" -type f)"
    echo "$files" | while read file; do
        local FILE_NAME=${file#$LEFT_DIR}
        local LEFT_FILE="$file"
        local RIGHT_FILE="$RIGHT_DIR""$FILE_NAME"
        if [ -f "$LEFT_FILE" ]; then
            if [ -f "$RIGHT_FILE" ]; then
                local LEFT_SIZE=( $( ls -Lon "$LEFT_FILE" ) )
                local LEFT_BYTES=${LEFT_SIZE[3]}
                local RIGHT_SIZE=( $( ls -Lon "$RIGHT_FILE" ) )
                local RIGHT_BYTES=${RIGHT_SIZE[3]}
                if [ "$LEFT_BYTES" -gt "$RIGHT_BYTES" ]; then
                    echo "REMOVED: $RIGHT_FILE"
                    rm "$RIGHT_FILE"
                elif [ "$RIGHT_BYTES" -gt "$LEFT_BYTES" ]; then
                    echo "REMOVED: $LEFT_FILE"
                    rm "$LEFT_FILE"
                else
                    echo "SKIPPED: $FILE_NAME (same size)"
                fi
            fi
        fi
    done
}
