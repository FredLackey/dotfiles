#!/bin/zsh
# fetch-github-repos - Clone all repositories from a GitHub organization
#
# Usage:
#   fetch-github-repos my-org ./cloned-repos
#
# Dependencies:
#   - git (brew install git)
#   - jq (brew install jq)
#   - curl (pre-installed on macOS)

fetch-github-repos() {
    local org="$1"
    local dest_dir="$2"

    if [ -z "$org" ] || [ -z "$dest_dir" ]; then
        echo "Usage: fetch-github-repos <organization> <destination-folder>"
        return 1
    fi

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

    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"

    # Fetch repositories
    echo "Fetching repositories for organization '$org'..."
    local repos
    repos=$(curl -s "https://api.github.com/orgs/$org/repos?per_page=100" | jq -r '.[].ssh_url')

    if [ -z "$repos" ]; then
        echo "No repositories found or failed to fetch from GitHub."
        return 1
    fi

    # Clone each repo
    for repo in $repos; do
        echo "Cloning $repo into $dest_dir..."
        git clone "$repo" "$dest_dir/$(basename -s .git "$repo")"
    done

    echo "All repositories have been cloned."
}
