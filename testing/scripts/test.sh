#!/bin/bash
# Test dotfiles installation in a specific Docker environment
#
# Usage:
#   ./test.sh <environment> [options]
#
# Environments:
#   ubuntu-server   - Test Ubuntu Server setup
#   ubuntu-desktop  - Test Ubuntu Desktop setup (CLI only)
#   ubuntu-wsl      - Test Ubuntu WSL setup
#
# Options:
#   --interactive   - Drop into shell instead of running setup
#   --local         - Mount local dotfiles instead of downloading from GitHub
#   --branch <name> - Use specific GitHub branch (default: main)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Default values
ENVIRONMENT=""
INTERACTIVE=false
LOCAL_MODE=false
BRANCH="main"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --local)
            LOCAL_MODE=true
            shift
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$ENVIRONMENT" ]; then
                ENVIRONMENT="$1"
            else
                echo "Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate environment
if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment> [options]"
    echo ""
    echo "Environments:"
    echo "  ubuntu-server   - Test Ubuntu Server setup"
    echo "  ubuntu-desktop  - Test Ubuntu Desktop setup (CLI only)"
    echo "  ubuntu-wsl      - Test Ubuntu WSL setup"
    echo ""
    echo "Options:"
    echo "  --interactive   - Drop into shell instead of running setup"
    echo "  --local         - Mount local dotfiles instead of downloading from GitHub"
    echo "  --branch <name> - Use specific GitHub branch (default: main)"
    exit 1
fi

IMAGE_NAME="dotfiles-test:$ENVIRONMENT"
CONTAINER_NAME="dotfiles-test-$ENVIRONMENT-$$"

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Error: Docker image '$IMAGE_NAME' not found."
    echo "Run ./testing/scripts/build.sh first."
    exit 1
fi

echo "========================================"
echo "Testing: $ENVIRONMENT"
echo "========================================"
echo "Image:       $IMAGE_NAME"
echo "Container:   $CONTAINER_NAME"
echo "Mode:        $([ "$LOCAL_MODE" = true ] && echo "Local" || echo "Remote (branch: $BRANCH)")"
echo "Interactive: $INTERACTIVE"
echo "========================================"
echo ""

# Build the docker run command
DOCKER_ARGS=(
    "run"
    "--rm"                              # Remove container when done
    "--name" "$CONTAINER_NAME"          # Name for identification
    "-e" "TERM=xterm-256color"          # Terminal support
)

# Add volume mount for local mode
if [ "$LOCAL_MODE" = true ]; then
    DOCKER_ARGS+=("-v" "$DOTFILES_DIR:/home/testuser/.dotfiles:ro")
fi

# Add image name
DOCKER_ARGS+=("$IMAGE_NAME")

# Build the command to run inside container
if [ "$INTERACTIVE" = true ]; then
    # Interactive mode - just start a shell
    DOCKER_ARGS=("${DOCKER_ARGS[@]:0:$((${#DOCKER_ARGS[@]}-1))}")  # Remove image name temporarily
    DOCKER_ARGS+=("-it")  # Add interactive terminal
    DOCKER_ARGS+=("$IMAGE_NAME")
    DOCKER_ARGS+=("bash")

    echo "Starting interactive shell..."
    echo "Run setup manually: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/$BRANCH/src/setup.sh)\""
    echo "Or if using --local: ~/.dotfiles/src/setup.sh"
    echo "Type 'exit' to leave and destroy container."
    echo ""

elif [ "$LOCAL_MODE" = true ]; then
    # Local mode - run setup.sh from mounted volume
    DOCKER_ARGS+=("bash" "-c" "
        echo 'Running local setup.sh...'
        echo ''
        cd ~/.dotfiles
        chmod +x src/setup.sh
        ./src/setup.sh
        EXIT_CODE=\$?
        echo ''
        if [ \$EXIT_CODE -eq 0 ]; then
            echo '========================================'
            echo 'TEST PASSED'
            echo '========================================'
        else
            echo '========================================'
            echo 'TEST FAILED (exit code: '\$EXIT_CODE')'
            echo '========================================'
        fi
        exit \$EXIT_CODE
    ")
else
    # Remote mode - download from GitHub and run
    SETUP_URL="https://raw.githubusercontent.com/FredLackey/dotfiles/$BRANCH/src/setup.sh"
    DOCKER_ARGS+=("bash" "-c" "
        echo 'Downloading setup.sh from GitHub (branch: $BRANCH)...'
        echo 'URL: $SETUP_URL'
        echo ''
        sh -c \"\$(curl -fsSL '$SETUP_URL')\"
        EXIT_CODE=\$?
        echo ''
        if [ \$EXIT_CODE -eq 0 ]; then
            echo '========================================'
            echo 'TEST PASSED'
            echo '========================================'
        else
            echo '========================================'
            echo 'TEST FAILED (exit code: '\$EXIT_CODE')'
            echo '========================================'
        fi
        exit \$EXIT_CODE
    ")
fi

# Run the container
docker "${DOCKER_ARGS[@]}"
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "Container exited successfully."
else
    echo "Container exited with code: $EXIT_CODE"
fi

exit $EXIT_CODE
