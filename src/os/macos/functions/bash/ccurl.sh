#!/bin/bash
# ccurl - Curl a URL and pretty-print JSON response with jq
#
# Usage:
#   ccurl https://api.example.com/data
#
# Dependencies:
#   - curl (pre-installed on macOS)
#   - jq (brew install jq)

ccurl() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed."
        echo "Install with: brew install jq"
        return 1
    fi

    # Check if URL was provided
    if [ -z "$1" ]; then
        echo "Usage: ccurl <URL>"
        return 1
    fi

    curl -s -H "Accept: application/json" "$1" | jq
}
