#!/bin/zsh
# dp - Display Docker containers in a formatted table
#
# Usage:
#   dp
#
# Dependencies:
#   - docker (Docker Desktop or brew install docker)

dp() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker is not currently installed."
        return 1
    fi

    docker ps --format '{{.ID}}\t{{.Names}}\t{{.Ports}}'
}
