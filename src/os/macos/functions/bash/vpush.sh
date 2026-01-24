#!/bin/bash
# vpush - Commit and push using package version as commit message
#
# Usage:
#   vpush
#
# Dependencies:
#   - git (brew install git)
#   - jq (brew install jq)

vpush() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: brew install jq"
        return 1
    fi

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    # Check if package.json exists
    if [ ! -f "package.json" ]; then
        echo "Error: package.json not found in current directory."
        return 1
    fi

    local pkg_ver
    pkg_ver=$(jq -r '.version' package.json)

    if [ -z "$pkg_ver" ] || [ "$pkg_ver" = "null" ]; then
        echo "Error: Could not read version from package.json"
        return 1
    fi

    git add -A
    git commit -a -S -m "$pkg_ver"
    git push origin master
}
