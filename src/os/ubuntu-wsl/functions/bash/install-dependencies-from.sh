#!/bin/bash
# Install dependencies listed in a specified package.json file.
#
# Usage:
#   install-dependencies-from ../source/package.json        # Install 'dependencies'
#   install-dependencies-from ../source/package.json dev    # Install 'devDependencies'

install-dependencies-from() {
    local package_json_path="$1"
    local dependency_type_prefix="${2:-dependencies}"
    local dependencies
    local npm_flag=""

    # Determine the npm flag based on the dependency type
    case "$dependency_type_prefix" in
        dev)
            npm_flag="--save-dev"
            ;;
        peer)
            npm_flag="--save-peer"
            ;;
        opt)
            npm_flag="--save-optional"
            ;;
        bundle)
            npm_flag="--save-bundled"
            ;;
        dependencies)
            npm_flag="--save"
            ;;
        *)
            echo "Error: Invalid dependency type prefix. Valid prefixes are: dev, peer, opt, bundle, dependencies."
            return 1
            ;;
    esac

    # Extract dependencies
    dependencies=$(get-dependencies "$package_json_path" "$dependency_type_prefix")

    if [[ -z "$dependencies" ]]; then
        echo "No dependencies to install."
        return 0
    fi

    # Install each dependency
    for dependency in $dependencies; do
        echo "Installing $dependency..."
        npm install "$dependency@latest" $npm_flag
    done
}
