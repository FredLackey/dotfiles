#!/bin/zsh
# get-dependencies - Extract dependency names from package.json
#
# Usage:
#   get-dependencies ./package.json          # Get 'dependencies'
#   get-dependencies ./package.json dev      # Get 'devDependencies'
#   get-dependencies ./package.json peer     # Get 'peerDependencies'
#   get-dependencies ./package.json opt      # Get 'optionalDependencies'
#   get-dependencies ./package.json bundle   # Get 'bundledDependencies'
#
# Dependencies:
#   - jq (brew install jq)

get-dependencies() {
    local package_json_path="$1"
    local dependency_type_prefix="${2:-dependencies}"
    local dependency_type=""

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: brew install jq"
        return 1
    fi

    # Check if a path was provided
    if [ -z "$package_json_path" ]; then
        echo "Usage: get-dependencies /path/to/package.json [dependency_type_prefix]"
        echo "Example: get-dependencies /path/to/package.json dev"
        return 1
    fi

    # Check if the package.json file exists
    if [ ! -f "$package_json_path" ]; then
        echo "Error: File not found: $package_json_path"
        return 1
    fi

    # Determine the full dependency type based on the prefix
    case "$dependency_type_prefix" in
        dev)
            dependency_type="devDependencies"
            ;;
        peer)
            dependency_type="peerDependencies"
            ;;
        opt)
            dependency_type="optionalDependencies"
            ;;
        bundle)
            dependency_type="bundledDependencies"
            ;;
        dependencies)
            dependency_type="dependencies"
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
        return 0
    fi

    # Extract dependencies using jq
    local dependencies
    dependencies=$(jq -r --arg depType "$dependency_type" '.[$depType] | keys[]?' "$package_json_path")
    if [ -z "$dependencies" ]; then
        return 0
    fi

    echo "$dependencies"
}
