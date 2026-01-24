#!/bin/zsh
# ncu-update-all - Update all npm/bower dependencies using npm-check-updates
#
# Usage:
#   ncu-update-all
#
# Dependencies:
#   - ncu (npm install -g npm-check-updates)

ncu-update-all() {
    # Check if ncu is installed
    if ! command -v ncu &> /dev/null; then
        echo "Error: ncu is required but not installed."
        echo "Install with: npm install -g npm-check-updates"
        return 1
    fi

    echo "Updating package.json files..."
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "Updating: $file"
            ncu -a -u --packageFile "$file"
        fi
    done < <(find . -type f -name "package.json" -not \( -path "*/node_modules/*" \) -not \( -path "*/bower_components/*" \))

    echo "Updating bower.json files..."
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            echo "Updating: $file"
            ncu -a -u -m bower --packageFile "$file"
        fi
    done < <(find . -type f -name "bower.json" -not \( -path "*/node_modules/*" \) -not \( -path "*/bower_components/*" \))

    echo "Update complete."
}
