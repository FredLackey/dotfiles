#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Configuring Ubuntu Server preferences..."
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

# Categories: SYSTEM, DEV, SECURITY

# Apply preferences in logical order:
# 1. System-wide settings first
run_preference "system.sh" "SYSTEM"

# 2. Git configuration
run_preference "git.sh" "DEV"

# 3. SSH server hardening (if SSH is installed)
run_preference "ssh.sh" "SECURITY"

echo "--------------------------------------------------"
echo "Ubuntu Server preferences configuration complete."
