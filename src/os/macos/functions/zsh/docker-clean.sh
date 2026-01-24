#!/bin/zsh
# docker-clean - Remove ALL Docker containers, images, and volumes
#
# Usage:
#   docker-clean
#
# WARNING: This action cannot be undone! Includes confirmation prompt.
#
# Dependencies:
#   - docker (Docker Desktop or brew install docker)

docker-clean() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Docker is not currently installed."
        return 1
    fi

    echo "This will remove ALL Docker containers, images, and volumes."
    echo "This action cannot be undone!"
    echo ""
    printf "Are you sure you want to continue? (y/N): "
    read -k 1 -r REPLY
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    echo "Proceeding with Docker cleanup..."

    # Delete all containers
    if docker ps -a -q | grep -q .; then
        echo "Removing all containers..."
        docker rm -f $(docker ps -a -q)
    else
        echo "No containers to remove."
    fi

    # Delete all images
    if docker images -q | grep -q .; then
        echo "Removing all images..."
        docker images -q | xargs docker rmi -f
    else
        echo "No images to remove."
    fi

    # Delete volumes
    if docker volume ls -q | grep -q .; then
        echo "Removing all volumes..."
        docker volume rm $(docker volume ls -q)
    else
        echo "No volumes to remove."
    fi

    echo "Docker cleanup completed."
}
