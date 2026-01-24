#!/bin/zsh
# evm - Execute a Vim macro on specified files
#
# Runs the macro stored in register 'q' on the specified files.
#
# Usage:
#   evm file.txt               # Run macro 'q' once on file.txt
#   evm file1.txt file2.txt 3  # Run macro 'q' 3 times on both files
#
# Dependencies:
#   - vim (brew install vim)

evm() {
    if [ $# -eq 0 ]; then
        echo "Usage: evm <file1> [file2 ...] [number_of_times]"
        return 1
    fi

    local numberOfTimes="${@[-1]}"
    local files

    if [[ "$numberOfTimes" =~ ^[0-9]+$ ]]; then
        files=("${@[1,-2]}")
    else
        numberOfTimes="1"
        files=("$@")
    fi

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Warning: File not found: $file"
            continue
        fi
        printf "* %s\n" "$file"
        vim \
            -c "norm! ${numberOfTimes}@q" \
            -c "wq" \
            "$file"
    done
}
