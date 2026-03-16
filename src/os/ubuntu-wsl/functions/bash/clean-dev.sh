#!/bin/bash
# Remove development artifact directories like `node_modules` and `bower_components`.
#
# Usage:
#   clean-dev

clean-dev() {
    echo "Removing node_modules directories..."
    sudo find . -name "node_modules" -exec rm -rf '{}' + 2>/dev/null
    echo "Removing bower_components directories..."
    find . -name "bower_components" -exec rm -rf '{}' + 2>/dev/null
    echo "Done."
}
