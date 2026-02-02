#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Configuring macOS system preferences..."
echo "=================================================="

# Check if a category is excluded via DOTFILES_EXCLUDE environment variable
# Usage: is_excluded "AI" returns 0 (true) if excluded, 1 (false) if not
is_excluded() {
    local category="$1"
    if [ -z "$DOTFILES_EXCLUDE" ]; then
        return 1
    fi
    # Convert both to uppercase for case-insensitive comparison
    local exclude_upper
    exclude_upper=$(echo "$DOTFILES_EXCLUDE" | tr '[:lower:]' '[:upper:]')
    local category_upper
    category_upper=$(echo "$category" | tr '[:lower:]' '[:upper:]')
    # Check if category appears in comma-separated list
    if echo ",$exclude_upper," | grep -q ",$category_upper,"; then
        return 0
    fi
    return 1
}

# Function to run a preference script
# Usage: run_preference "script.sh" "CATEGORY"
run_preference() {
    local script_name="$1"
    local category="$2"
    local script_path="$SCRIPT_DIR/$script_name"

    # Skip if category is excluded
    if [ -n "$category" ] && is_excluded "$category"; then
        echo "--------------------------------------------------"
        echo "Skipping preference (excluded category $category): $script_name"
        return 0
    fi

    if [ -f "$script_path" ]; then
        echo "--------------------------------------------------"
        bash "$script_path"
    else
        echo "Error: Preference script not found: $script_name"
        exit 1
    fi
}

# Categories: SYSTEM, DESKTOP, TERMINAL, DEV, SECURITY

# Apply preferences in logical order:
# 1. System-wide settings first
run_preference "global.sh" "SYSTEM"

# 2. Desktop and window management
run_preference "dock.sh" "DESKTOP"
run_preference "hot-corners.sh" "DESKTOP"
run_preference "finder.sh" "DESKTOP"

# 3. Input devices
run_preference "trackpad.sh" "DESKTOP"

# 4. Menu bar
run_preference "menu-bar.sh" "DESKTOP"
run_preference "clock.sh" "DESKTOP"

# 5. Utilities and apps
run_preference "screenshots.sh" "DESKTOP"
run_preference "textedit.sh" "DESKTOP"

# 6. Terminal appearance
run_preference "terminal-theme.sh" "TERMINAL"

echo "--------------------------------------------------"
echo "macOS system preferences configuration complete."
