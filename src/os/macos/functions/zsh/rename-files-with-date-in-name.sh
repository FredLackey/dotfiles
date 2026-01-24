#!/bin/zsh
# rename-files-with-date-in-name - Rename files to standardized date format
#
# Renames files containing dates in the filename to: YYYY-MM-DD HH.MM.SS.ext
#
# Usage:
#   rename-files-with-date-in-name path/to/directory
#   rename-files-with-date-in-name path/to/file.jpg
#
# Supported formats:
#   - 20200505_050505.dng -> 2020-05-05 05.05.05.dng
#   - Screenshot 2020-01-02 at 03.04.05.png -> 2020-01-02 03.04.05.png
#   - signal-2020-05-06-07-08-09-123.mp4 -> 2020-05-06 07.08.09.mp4
#
# Dependencies: None (uses built-in sed and find)

rename-files-with-date-in-name() (
    rename_file() (
        local filePath
        local fileName
        local newFilePath

        filePath=$(dirname "${1%/}")
        fileName=$(basename "$1")

        # Transform various date formats to: YYYY-MM-DD HH.MM.SS.ext
        newFilePath="${filePath}/$(printf "%s" "$fileName" | sed 's/[^0-9]*\([0-9]\{4\}\)[_-]\{0,1\}\([0-9]\{2\}\)[_-]\{0,1\}\([0-9]\{2\}\)[_-]\{0,1\}\( at \)\{0,1\}\([0-9]\{2\}\)[_.-]\{0,1\}\([0-9]\{2\}\)[_.-]\{0,1\}\([0-9]\{2\}\).*\(\..*\)$/\1-\2-\3 \5.\6.\7\8/')"

        if [ "$newFilePath" != "$1" ]; then
            mv -f "$1" "$newFilePath"
        fi
    )

    # Default to current directory if no argument provided
    for filePath in "${@:-.}"; do
        if [ -d "$filePath" ]; then
            find "${filePath%/}" \
                -type f \
                -depth 1 \
                -print \
            | while read -r f; do
                rename_file "$f"
            done
        elif [ -f "$filePath" ]; then
            rename_file "$filePath"
        fi
    done
)
