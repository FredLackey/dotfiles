#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFERENCES_DIR="$SCRIPT_DIR/preferences"

echo "Running Ubuntu Desktop setup..."

apply_preferences() {
    local prefs_script="$PREFERENCES_DIR/setup.sh"

    if [ -f "$prefs_script" ]; then
        bash "$prefs_script"
    else
        echo "Warning: Preferences setup script not found: $prefs_script"
    fi
}

apply_preferences

echo ""
echo "Setup complete. Please log out and back in for keyboard changes to take full effect."
