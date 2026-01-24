#!/bin/zsh
# get-folder - Copy files from source to target, skipping existing same-size files
#
# Usage:
#   get-folder /path/to/source/ /path/to/target/
#
# Dependencies:
#   - rsync (pre-installed on macOS)

get-folder() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: get-folder <source-path> <target-path>"
        return 1
    fi

    # Ensure source and target paths end with a forward slash
    local source="${1%/}/"
    local target="${2%/}/"

    # Check if rsync command exists
    if command -v rsync &> /dev/null; then
        # Use rsync if available
        for file in "$source"*; do
            local filename
            filename=$(basename "$file")
            if [ -f "$target$filename" ]; then
                # Check if file size matches (macOS stat syntax)
                local source_size target_size
                source_size=$(stat -f %z "$file" 2>/dev/null || stat -c %s "$file" 2>/dev/null)
                target_size=$(stat -f %z "$target$filename" 2>/dev/null || stat -c %s "$target$filename" 2>/dev/null)
                if [ "$source_size" -eq "$target_size" ]; then
                    echo "Skipping $filename as it already exists and has the same size."
                else
                    rsync -avP "$file" "$target"
                fi
            else
                rsync -avP "$file" "$target"
            fi
        done
    else
        echo "Error: rsync command not found."
        return 1
    fi
}
