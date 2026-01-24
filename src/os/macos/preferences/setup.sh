#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Configuring macOS system preferences..."
echo "=================================================="

# Function to run a preference script
run_preference() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"

    if [ -f "$script_path" ]; then
        echo "--------------------------------------------------"
        bash "$script_path"
    else
        echo "Error: Preference script not found: $script_name"
        exit 1
    fi
}

# Apply preferences in logical order:
# 1. System-wide settings first
run_preference "global.sh"

# 2. Desktop and window management
run_preference "dock.sh"
run_preference "hot-corners.sh"
run_preference "finder.sh"

# 3. Input devices
run_preference "trackpad.sh"

# 4. Menu bar
run_preference "menu-bar.sh"
run_preference "clock.sh"

# 5. Utilities and apps
run_preference "screenshots.sh"
run_preference "textedit.sh"

echo "--------------------------------------------------"
echo "macOS system preferences configuration complete."
