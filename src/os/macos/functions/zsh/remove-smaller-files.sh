#!/bin/zsh
# remove-smaller-files - Remove smaller version of duplicate files
#
# Compares files in the current directory with another directory and
# removes the smaller version of each duplicate pair.
#
# Usage:
#   remove-smaller-files /path/to/other/directory
#
# Dependencies: None (uses built-in commands)

remove-smaller-files() {
    if [ -z "$1" ]; then
        echo "Usage: remove-smaller-files <other-directory>"
        return 1
    fi

    local LEFT_DIR="$PWD"
    local RIGHT_DIR="$1"

    if [ ! -d "$RIGHT_DIR" ]; then
        echo "Error: Directory does not exist: $RIGHT_DIR"
        return 1
    fi

    echo "LEFT : $LEFT_DIR"
    echo "RIGHT: $RIGHT_DIR"

    local files
    files="$(find -L "$LEFT_DIR" -type f)"

    echo "$files" | while read -r file; do
        local FILE_NAME="${file#$LEFT_DIR}"
        local LEFT_FILE="$file"
        local RIGHT_FILE="$RIGHT_DIR$FILE_NAME"

        if [ -f "$LEFT_FILE" ]; then
            if [ -f "$RIGHT_FILE" ]; then
                local LEFT_SIZE RIGHT_SIZE LEFT_BYTES RIGHT_BYTES

                LEFT_SIZE=( $( ls -Lon "$LEFT_FILE" ) )
                LEFT_BYTES=${LEFT_SIZE[3]}
                RIGHT_SIZE=( $( ls -Lon "$RIGHT_FILE" ) )
                RIGHT_BYTES=${RIGHT_SIZE[3]}

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
