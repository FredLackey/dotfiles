#!/bin/bash
# Curl a URL, expecting JSON, and pretty-print the output using jq.
#
# Usage:
#   ccurl https://api.example.com/data

ccurl() {
    if [ -z "$1" ]; then
        echo "Usage: ccurl <URL>"
        return 1
    fi
    curl -s -H "Accept: application/json" "$1" | jq
}
