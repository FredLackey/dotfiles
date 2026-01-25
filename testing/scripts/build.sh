#!/bin/bash
# Build all Docker test images
# Run this once before testing, or after modifying Dockerfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

echo "========================================"
echo "Building Docker Test Images"
echo "========================================"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running."
    echo "Please start Docker and try again."
    exit 1
fi

# Build each environment
ENVIRONMENTS=("ubuntu-server" "ubuntu-desktop" "ubuntu-wsl")

for ENV in "${ENVIRONMENTS[@]}"; do
    DOCKERFILE="$DOCKER_DIR/$ENV.Dockerfile"
    IMAGE_NAME="dotfiles-test:$ENV"

    if [ ! -f "$DOCKERFILE" ]; then
        echo "Warning: $DOCKERFILE not found, skipping."
        continue
    fi

    echo "Building $IMAGE_NAME..."
    docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" "$DOCKER_DIR"
    echo "  Done: $IMAGE_NAME"
    echo ""
done

echo "========================================"
echo "Build Complete"
echo "========================================"
echo ""
echo "Images created:"
docker images | grep "dotfiles-test" || echo "  (none)"
echo ""
echo "Next step: Run tests with ./testing/scripts/test.sh <environment>"
