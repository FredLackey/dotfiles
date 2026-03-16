#!/bin/bash
# Remove all Docker containers, images, and volumes.
#
# Usage:
#   docker-clean

docker-clean() {
    echo "This will remove ALL Docker containers, images, and volumes."
    echo "This action cannot be undone!"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    echo "Proceeding with Docker cleanup..."

    # Delete all containers
    if docker ps -a -q 2>/dev/null | grep -q .; then
        echo "Removing all containers..."
        docker rm -f $(docker ps -a -q)
    else
        echo "No containers to remove."
    fi

    # Delete all images
    if docker images -q 2>/dev/null | grep -q .; then
        echo "Removing all images..."
        docker images -q | xargs docker rmi -f
    else
        echo "No images to remove."
    fi

    # Delete volumes
    if docker volume ls -q 2>/dev/null | grep -q .; then
        echo "Removing all volumes..."
        docker volume rm $(docker volume ls -q)
    else
        echo "No volumes to remove."
    fi

    echo "Docker cleanup completed."
}
