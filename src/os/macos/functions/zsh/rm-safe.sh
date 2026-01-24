#!/bin/zsh
# rm-safe - Safe wrapper around rm to prevent accidental root removal
#
# Blocks attempts to remove '/', '/some_dir', '/*', or using '--no-preserve-root'.
#
# Usage:
#   rm_safe file.txt directory/
#   rm_safe -rf old_files/
#
# Note: Set alias rm='rm_safe' to make this the default behavior.
#
# Dependencies: None (wraps built-in rm)

rm_safe() {
    # Iterate over the arguments
    for arg in "$@"; do
        # Check if the argument is the root directory "/"
        if [ "$arg" = "/" ]; then
            echo "Error: Attempt to remove the root directory is forbidden!"
            return 1
        fi

        # Check if the argument is any single directory in the root (e.g., "/bin", "/etc")
        if [[ "$arg" =~ ^/[^/]+$ ]]; then
            echo "Error: Attempt to remove a top-level directory is forbidden!"
            return 1
        fi

        # Check if the argument is the wildcard pattern "/*"
        if [ "$arg" = "/*" ]; then
            echo "Error: Attempt to remove all files and directories in the root is forbidden!"
            return 1
        fi
    done

    # Check if the arguments contain "--no-preserve-root"
    for arg in "$@"; do
        if [ "$arg" = "--no-preserve-root" ]; then
            echo "Error: Use of --no-preserve-root is forbidden!"
            return 1
        fi
    done

    # Run the actual rm command with the original arguments
    command rm "$@"
}
