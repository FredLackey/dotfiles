#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$SCRIPT_DIR/installers"
PREFERENCES_DIR="$SCRIPT_DIR/preferences"

# ---------------------------------------------------------------------------
# Logging — write a timestamped log to the Windows Desktop when running in WSL
# ---------------------------------------------------------------------------
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE=""

if [ -n "$WSL_DISTRO_NAME" ]; then
    WIN_USERPROFILE=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r\n')
    if [ -n "$WIN_USERPROFILE" ]; then
        WIN_DESKTOP=$(wslpath "$WIN_USERPROFILE\\Desktop" 2>/dev/null || echo "")
        if [ -n "$WIN_DESKTOP" ] && [ -d "$WIN_DESKTOP" ]; then
            LOG_FILE="$WIN_DESKTOP/dotfiles-wsl-$TIMESTAMP.log"
        fi
    fi
fi

if [ -n "$LOG_FILE" ]; then
    echo "Logging to: $LOG_FILE"
    exec > >(tee -a "$LOG_FILE") 2>&1
fi

echo "Running Ubuntu WSL setup..."

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

# Function to run an installer script
# Usage: run_installer "script.sh" "CATEGORY"
run_installer() {
    local script_name="$1"
    local category="$2"
    local script_path="$INSTALLERS_DIR/$script_name"

    # Skip if category is excluded
    if [ -n "$category" ] && is_excluded "$category"; then
        echo "--------------------------------------------------"
        echo "Skipping installer (excluded category $category): $script_name"
        return 0
    fi

    if [ -f "$script_path" ]; then
        echo "--------------------------------------------------"
        echo "Running installer: $script_name"
        if [ -n "$LOG_FILE" ]; then
            # Log file active: verbose output goes to log only, console stays clean
            bash "$script_path" >> "$LOG_FILE" 2>&1
        else
            # No log file: suppress output (console stays clean)
            bash "$script_path" >/dev/null 2>&1
        fi
    else
        echo "Error: Installer script not found: $script_name"
        exit 1
    fi
}

install_applications() {
    echo "Starting application installation..."

    # Categories: SYSTEM, LANGUAGES, TERMINAL, DEV, DEVOPS, UTILS, MEDIA, SECURITY, AI, APPS

    # 1. System Prerequisites
    run_installer "apt-update.sh" "SYSTEM"
    run_installer "build-essential.sh" "SYSTEM"

    # 2. Core CLI Tools
    run_installer "git.sh" "DEV"
    run_installer "github-cli.sh" "DEV"
    run_installer "curl.sh" "UTILS"
    run_installer "wget.sh" "UTILS"
    run_installer "gpg.sh" "UTILS"

    # 3. Shell Configuration (core - deploy early so PATH is set)
    run_installer "shell-config.sh" "SYSTEM"

    # 4. Starship Prompt
    run_installer "starship.sh" "SYSTEM"
    run_installer "starship-config.sh" "SYSTEM"

    # 5. Node.js (NVM + Node)
    run_installer "nvm.sh" "LANGUAGES"

    # Reload NVM environment (required for npm-dependent installers)
    if ! command -v npm >/dev/null; then
        echo "Loading NVM environment..."
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi

        if command -v npm >/dev/null; then
            echo "NVM loaded into memory."
        else
            echo "Warning: Failed to load NVM into memory. npm-dependent installs may fail."
        fi
    fi

    run_installer "node.sh" "LANGUAGES"
    run_installer "yarn.sh" "LANGUAGES"
    run_installer "npm-packages.sh" "LANGUAGES"

    # 6. Languages & Runtimes
    run_installer "go.sh" "LANGUAGES"
    run_installer "gitego.sh" "DEV"
    run_installer "python.sh" "LANGUAGES"

    # 7. CLI Utilities
    run_installer "jq.sh" "UTILS"
    run_installer "yq.sh" "UTILS"
    run_installer "tree.sh" "UTILS"
    run_installer "shellcheck.sh" "DEV"
    run_installer "pandoc.sh" "UTILS"
    run_installer "tmux.sh" "UTILS"
    run_installer "vim.sh" "DEV"
    run_installer "htop.sh" "UTILS"
    run_installer "rsync.sh" "UTILS"
    run_installer "nmap.sh" "SECURITY"
    run_installer "imagemagick.sh" "MEDIA"
    run_installer "ffmpeg.sh" "MEDIA"
    run_installer "bash-completion.sh" "UTILS"
    run_installer "yt-dlp.sh" "MEDIA"

    # 8. Infrastructure & DevOps
    run_installer "aws-cli.sh" "DEVOPS"
    run_installer "tfenv.sh" "DEVOPS"
    run_installer "terraform.sh" "DEVOPS"

    # 9. AI Tools
    run_installer "claude-code.sh" "AI"

    # 10. Marcus Developer Tools (td must be first — other tools reference it)
    run_installer "td.sh" "APPS"
    run_installer "sidecar.sh" "APPS"

    # 11. Cleanup
    run_installer "apt-cleanup.sh" "SYSTEM"

    echo "Application installation complete."
}

apply_preferences() {
    local prefs_script="$PREFERENCES_DIR/setup.sh"

    if [ -f "$prefs_script" ]; then
        if [ -n "$LOG_FILE" ]; then
            bash "$prefs_script" >> "$LOG_FILE" 2>&1
        else
            bash "$prefs_script" >/dev/null 2>&1
        fi
    else
        echo "Warning: Preferences setup script not found: $prefs_script"
    fi
}

# Execute installation
install_applications

# Apply system preferences
apply_preferences

echo ""
echo "Setup complete. Please log out and back in (or run 'source ~/.bashrc') to activate the new shell configuration."

if [ -n "$LOG_FILE" ]; then
    echo ""
    echo "Log saved to: $LOG_FILE"
fi
