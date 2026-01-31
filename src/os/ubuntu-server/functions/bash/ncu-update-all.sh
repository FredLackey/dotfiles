#!/bin/bash
# Update npm and bower dependencies using ncu across the project.
#
# Usage:
#   ncu-update-all

ncu-update-all() {
    if ! command -v ncu &>/dev/null; then
        printf "ncu is required, please install it!\n"
        return 1
    fi

    for file in $(find . -type f -name "package.json" -not \( -path "*/node_modules/*" \) -not \( -path "*/bower_components/*" \)); do
        if [ -f "$file" ]; then
            echo "Updating: $file"
            ncu -a -u --packageFile "$file"
        fi
    done

    for file in $(find . -type f -name "bower.json" -not \( -path "*/node_modules/*" \) -not \( -path "*/bower_components/*" \)); do
        if [ -f "$file" ]; then
            echo "Updating: $file"
            ncu -a -u -m bower --packageFile "$file"
        fi
    done
}
