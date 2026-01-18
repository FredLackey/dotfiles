#!/bin/bash
set -e

REPO_URL="https://github.com/FredLackey/dotfiles/archive/refs/heads/main.zip"
TARGET_DIR="$HOME/.dotfiles"
TEMP_DIR="$(mktemp -d)"

# 2. Download & Extract (Idempotent)
if [ -d "$TARGET_DIR" ]; then
    echo "Files already present in $TARGET_DIR. Skipping download."
else
    echo "Downloading dotfiles..."
    # Ensure curl and unzip exist
    if ! command -v curl >/dev/null 2>&1; then
        echo "Error: curl is required."
        exit 1
    fi
    if ! command -v unzip >/dev/null 2>&1; then
        echo "Error: unzip is required."
        exit 1
    fi

    curl -fsSL "$REPO_URL" -o "$TEMP_DIR/dotfiles.zip"
    unzip -q "$TEMP_DIR/dotfiles.zip" -d "$TEMP_DIR"
    mv "$TEMP_DIR/dotfiles-main" "$TARGET_DIR"
    rm -rf "$TEMP_DIR"
fi

# 3. OS/Environment Detection
OS="$(uname -s)"
SCRIPT_TO_RUN=""

# Determine source directory
# Logic: use local directory if script is running from file, otherwise (curl) use downloaded TARGET_DIR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
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

# 4. Execution
if [ -n "$SCRIPT_TO_RUN" ] && [ -f "$SCRIPT_TO_RUN" ]; then
    chmod +x "$SCRIPT_TO_RUN"
    "$SCRIPT_TO_RUN"
else
    echo "Error: Could not determine setup script or script not found: $SCRIPT_TO_RUN"
    exit 1
fi
