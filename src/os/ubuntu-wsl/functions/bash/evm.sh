#!/bin/bash
# Execute Vim macro on specified files.
#
# Usage:
#   evm file1.txt file2.txt 3  # Run macro 'q' 3 times on file1.txt and file2.txt
#   evm file.txt               # Run macro 'q' 1 time on file.txt

evm() {
    local numberOfTimes="${*: -1}"
    local files

    if [[ "$numberOfTimes" =~ ^[0-9]+$ ]]; then
        files=("${@:1:$#-1}")
    else
        numberOfTimes="1"
        files=("$@")
    fi

    for file in "${files[@]}"; do
        printf "* %s\n" "$file"
        vim \
            -c "norm! $numberOfTimes@q" \
            -c "wq" \
            "$file"
    done
}
