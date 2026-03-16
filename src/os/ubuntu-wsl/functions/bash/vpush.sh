#!/bin/bash
# Commit and push a Node project using the package version as the commit message.
#
# Usage:
#   vpush

vpush() {
    # Ensure JQ is installed
    if ! command -v jq >/dev/null 2>&1; then
        printf "jq is required, please install it!\n"
        return 1
    fi

    if [ ! -f "package.json" ]; then
        printf "No package.json found in current directory.\n"
        return 1
    fi

    pkg_ver=$(jq '.version' package.json)
    pkg_ver=${pkg_ver//\"/}
    git add -A
    git commit -a -S -m "$pkg_ver"
    git push origin master
}
