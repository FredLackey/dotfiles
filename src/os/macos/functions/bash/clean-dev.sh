#!/bin/bash
# clean-dev - Remove node_modules and bower_components recursively
#
# Usage:
#   clean-dev
#
# Dependencies: None (uses built-in find)

clean-dev() {
    echo "Removing node_modules directories..."
    find . -name "node_modules" -type d -exec rm -rf '{}' + 2>/dev/null

    echo "Removing bower_components directories..."
    find . -name "bower_components" -type d -exec rm -rf '{}' + 2>/dev/null

    echo "Clean complete."
}
