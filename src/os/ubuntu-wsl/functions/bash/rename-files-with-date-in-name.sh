#!/bin/bash
# From the specified files, rename the files containing a date
# in the filename to only the date in the following format:
#
#    <year>-<month>-<day> <hour>.<minute>.<second>
#
# Usage:
#   rename-files-with-date-in-name path/to/some/directory path/to/some/file ...

rename-files-with-date-in-name() (
    rename_file() (
        filePath=$(dirname "${1%/}")
        fileName=$(basename "$1")

        # The following will do transformations such as:
        #
        #   * 20200505_050505.dng => 2020-05-05 05.05.05.dng
        #   * Screenshot 2020-01-02 at 03.04.05.png => 2020-01-02 03-04-05.jpg
        #   * Screenshot_20201010-101010_Something.jpg => 2020-10-10 10-10-10.jpg
        #   * signal-2020-05-06-07-08-09-123.mp4 => 2020-05-06 07-08-09.mp4

        newFilePath="${filePath}/$(printf "%s" "$fileName" | sed 's/[^0-9]*\([0-9]\{4\}\)[_-]\{0,1\}\([0-9]\{2\}\)[_-]\{0,1\}\([0-9]\{2\}\)[_-]\{0,1\}\( at \)\{0,1\}\([0-9]\{2\}\)[_.-]\{0,1\}\([0-9]\{2\}\)[_.-]\{0,1\}\([0-9]\{2\}\).*\(\..*\)$/\1-\2-\3 \5.\6.\7\8/')"

        if [ "$newFilePath" != "$1" ]; then
           mv -f "$1" "$newFilePath"
        fi
    )

    #                 ┌─ Default to the current directory.
    for filePath in "${@:-.}"; do
        if [ -d "$filePath" ]; then
            find "${filePath%/}" \
                -type f \
                -maxdepth 1 \
                -print \
            | while read -r f; do
                rename_file "$f"
            done
        elif [ -f "$filePath" ]; then
            rename_file "$filePath"
        fi
    done
)
