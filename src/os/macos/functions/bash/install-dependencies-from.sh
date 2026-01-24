#!/bin/bash
# install-dependencies-from - Install dependencies from another package.json
#
# Usage:
#   install-dependencies-from ../source/package.json        # Install 'dependencies'
#   install-dependencies-from ../source/package.json dev    # Install as devDependencies
#
# Dependencies:
#   - npm (included with Node.js)
#   - jq (brew install jq)

install-dependencies-from() {
    local package_json_path="$1"
    local dependency_type_prefix="${2:-dependencies}"
    local dependency_type=""
    local dependencies
    local npm_flag=""

    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is required but not installed."
        return 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: brew install jq"
        return 1
    fi

    # Check if a path was provided
    if [ -z "$package_json_path" ]; then
        echo "Usage: install-dependencies-from /path/to/package.json [dependency_type_prefix]"
        echo "Example: install-dependencies-from ../source/package.json dev"
        return 1
    fi

    # Check if the package.json file exists
    if [ ! -f "$package_json_path" ]; then
        echo "Error: File not found: $package_json_path"
        return 1
    fi

    # Determine the full dependency type and npm flag based on the prefix
    case "$dependency_type_prefix" in
        dev)
            dependency_type="devDependencies"
            npm_flag="--save-dev"
            ;;
        peer)
            dependency_type="peerDependencies"
            npm_flag="--save-peer"
            ;;
        opt)
            dependency_type="optionalDependencies"
            npm_flag="--save-optional"
            ;;
        bundle)
            dependency_type="bundledDependencies"
            npm_flag="--save-bundled"
            ;;
        dependencies)
            dependency_type="dependencies"
            npm_flag="--save"
            ;;
        *)
            echo "Error: Invalid dependency type prefix. Valid prefixes are: dev, peer, opt, bundle, dependencies."
            return 1
            ;;
    esac

    # Check if the dependency type node exists and is not null
    local node_exists
    node_exists=$(jq -e --arg depType "$dependency_type" '.[$depType] != null' "$package_json_path")
    if [ $? -ne 0 ] || [ "$node_exists" != "true" ]; then
        echo "No $dependency_type found in $package_json_path"
        return 0
    fi

    # Extract dependencies using jq
    dependencies=$(jq -r --arg depType "$dependency_type" '.[$depType] | keys[]?' "$package_json_path")

    if [ -z "$dependencies" ]; then
        echo "No dependencies to install."
        return 0
    fi

    # Install each dependency
    for dependency in $dependencies; do
        echo "Installing $dependency..."
        npm install "$dependency@latest" $npm_flag
    done
}
