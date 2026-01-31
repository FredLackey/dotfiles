#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Configuring Ubuntu Server preferences..."
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
run_preference "system.sh"

# 2. Git configuration
run_preference "git.sh"

# 3. SSH server hardening (if SSH is installed)
run_preference "ssh.sh"

echo "--------------------------------------------------"
echo "Ubuntu Server preferences configuration complete."
