#!/bin/bash
# refresh-files - Refresh files in target from source (only overwrites existing)
#
# Compares files in target to source and copies over local copies with
# source version if both exist. Useful for protecting critical files.
#
# Usage:
#   refresh-files /path/to/source/            # Target defaults to current directory
#   refresh-files /path/to/source/ /path/to/target/
#
# Dependencies: None (uses built-in find and cp)

refresh-files() {
    local usage="refresh-files SOURCE_FOLDER [TARGET_FOLDER]"
    local source="$1"
    local target="${2:-${PWD}}"
    local noise="$3"
    local err=""
    local relpath=""
    local from=""
    local counter=0

    if [ -z "$source" ]; then
        err="Source folder not supplied."
    elif [ ! -d "$source" ]; then
        err="Source folder does not exist."
    elif [ ! -d "$target" ]; then
        err="Target folder does not exist: $target"
    elif [ -n "$noise" ]; then
        err="Extra noise supplied in command."
    fi

    if [ "$err" != "" ]; then
        echo "Problem refreshing files: $err"
        echo ""
        echo "USAGE: $usage"
        return 1
    fi

    echo "Refreshing files..."
    echo "FROM: $source"
    echo "TO  : $target"
    echo "-----"

    while IFS= read -r file; do
        relpath=$(echo "$file" | sed "s@$target@@")
        from=${source%/}${relpath}

        if [ -f "$from" ]; then
            echo "$relpath"
            cp "$from" "$file"
            counter=$((counter+1))
        fi
    done < <(find "$target" -type f -not \( -path "*/node_modules/*" \) -not \( -path "*/bower_components/*" \))

    echo "-----"
    echo "Files refreshed: $counter"
}
