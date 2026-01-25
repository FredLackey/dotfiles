#!/bin/bash
# Clean up all Docker test containers and images
#
# Usage:
#   ./clean.sh [options]
#
# Options:
#   --images    - Also remove Docker images (default: containers only)
#   --all       - Remove everything (containers + images)

set -e

REMOVE_IMAGES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --images|--all)
            REMOVE_IMAGES=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "========================================"
echo "Cleaning Docker Test Resources"
echo "========================================"
echo ""

# Stop and remove any running test containers
echo "Stopping test containers..."
CONTAINERS=$(docker ps -a --filter "name=dotfiles-test-" --format "{{.Names}}" 2>/dev/null || true)
if [ -n "$CONTAINERS" ]; then
    echo "$CONTAINERS" | xargs -r docker rm -f
    echo "  Removed containers."
else
    echo "  No test containers found."
fi
echo ""

# Remove images if requested
if [ "$REMOVE_IMAGES" = true ]; then
    echo "Removing test images..."
    IMAGES=$(docker images --filter "reference=dotfiles-test:*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
    if [ -n "$IMAGES" ]; then
        echo "$IMAGES" | xargs -r docker rmi -f
        echo "  Removed images."
    else
        echo "  No test images found."
    fi
    echo ""
fi

echo "========================================"
echo "Cleanup Complete"
echo "========================================"

# Show remaining resources
echo ""
echo "Remaining test containers:"
docker ps -a --filter "name=dotfiles-test-" --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  (none)"

echo ""
echo "Remaining test images:"
docker images --filter "reference=dotfiles-test:*" --format "  {{.Repository}}:{{.Tag}}" 2>/dev/null || echo "  (none)"
