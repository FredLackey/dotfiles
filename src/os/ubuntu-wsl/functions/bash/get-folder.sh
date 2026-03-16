#!/bin/bash
# Copy files from a source to a target directory, comparing sizes (using rsync).
# Skips files if they exist in the target with the same size.
#
# Usage:
#   get-folder /path/to/source/ /path/to/target/

get-folder() {
    # Ensure source and target paths end with a forward slash
    local source="${1%/}/"
    local target="${2%/}/"

    # Check if rsync command exists
    if ! command -v rsync &>/dev/null; then
        echo "Error: rsync command not found."
        return 1
    fi

    for file in "$source"*; do
        local filename=$(basename "$file")
        if [ -f "$target$filename" ]; then
            # Check if file size matches
            local source_size=$(stat -c %s "$file")
            local target_size=$(stat -c %s "$target$filename")
            if [ "$source_size" -eq "$target_size" ]; then
                echo "Skipping $filename as it already exists and has the same size."
            else
                rsync -avP "$file" "$target"
            fi
        else
            rsync -avP "$file" "$target"
        fi
    done
}
