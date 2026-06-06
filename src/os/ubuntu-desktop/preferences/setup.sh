#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Configuring Ubuntu Desktop preferences..."
echo "=================================================="

is_excluded() {
    local category="$1"
    if [ -z "$DOTFILES_EXCLUDE" ]; then
        return 1
    fi

    local exclude_upper
    exclude_upper=$(echo "$DOTFILES_EXCLUDE" | tr '[:lower:]' '[:upper:]')
    local category_upper
    category_upper=$(echo "$category" | tr '[:lower:]' '[:upper:]')

    if echo ",$exclude_upper," | grep -q ",$category_upper,"; then
        return 0
    fi

    return 1
}

run_preference() {
    local script_name="$1"
    local category="$2"
    local script_path="$SCRIPT_DIR/$script_name"

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

# Categories: SYSTEM, DESKTOP, DEV

run_preference "keyboard.sh" "SYSTEM"

echo "--------------------------------------------------"
echo "Ubuntu Desktop preferences configuration complete."
