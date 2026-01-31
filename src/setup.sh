#!/bin/bash
set -e

REPO_URL="https://github.com/FredLackey/dotfiles/tarball/main"
TARGET_DIR="$HOME/.dotfiles"
TEMP_FILE="$(mktemp)"

# 1. Download & Extract (Idempotent)
if [ -d "$TARGET_DIR" ]; then
    echo "Files already present in $TARGET_DIR. Skipping download."
else
    echo "Downloading dotfiles..."
    # Ensure curl and tar exist (both are standard on macOS and Linux)
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl is required."
        exit 1
    fi
    if ! command -v tar >/dev/null 2>&1; then
        echo "Error: tar is required."
        exit 1
    fi

    # Download tarball and extract
    mkdir -p "$TARGET_DIR"
    curl -fsSL "$REPO_URL" -o "$TEMP_FILE"
    tar -xzf "$TEMP_FILE" -C "$TARGET_DIR" --strip-components=1
    rm -f "$TEMP_FILE"
fi

# 2. OS/Environment Detection
OS="$(uname -s)"
SCRIPT_TO_RUN=""

# Determine source directory
# Logic: use local directory if script is running from file, otherwise (curl) use downloaded TARGET_DIR
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ ! -d "$SCRIPT_DIR/os" ]; then
    SCRIPT_DIR="$TARGET_DIR/src"
fi

if [ "$OS" = "Darwin" ]; then
    SCRIPT_TO_RUN="$SCRIPT_DIR/os/macos/setup.sh"
elif [ "$OS" = "Linux" ]; then
    # Check WSL
    if grep -qEi "(Microsoft|WSL)" /proc/version || [ -n "$WSL_DISTRO_NAME" ]; then
        SCRIPT_TO_RUN="$SCRIPT_DIR/os/ubuntu-wsl/setup.sh"
    # Check Desktop
    elif [ -n "$XDG_CURRENT_DESKTOP" ]; then
         SCRIPT_TO_RUN="$SCRIPT_DIR/os/ubuntu-desktop/setup.sh"
    else
         SCRIPT_TO_RUN="$SCRIPT_DIR/os/ubuntu-server/setup.sh"
    fi
fi

# 3. Execution
if [ -n "$SCRIPT_TO_RUN" ] && [ -f "$SCRIPT_TO_RUN" ]; then
    chmod +x "$SCRIPT_TO_RUN"
    "$SCRIPT_TO_RUN"
else
    echo "Error: Could not determine setup script or script not found: $SCRIPT_TO_RUN"
    exit 1
fi
