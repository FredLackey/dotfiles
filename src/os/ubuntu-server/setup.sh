#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$SCRIPT_DIR/installers"
PREFERENCES_DIR="$SCRIPT_DIR/preferences"

echo "Running Ubuntu Server setup..."

# Function to run an installer script
run_installer() {
    local script_name="$1"
    local script_path="$INSTALLERS_DIR/$script_name"

    if [ -f "$script_path" ]; then
        echo "--------------------------------------------------"
        echo "Running installer: $script_name"
        bash "$script_path"
    else
        echo "Error: Installer script not found: $script_name"
        exit 1
    fi
}

install_applications() {
    echo "Starting application installation..."

    # 1. System Prerequisites
    run_installer "apt-update.sh"
    run_installer "build-essential.sh"

    # 2. Core CLI Tools
    run_installer "git.sh"
    run_installer "curl.sh"

    # 3. Node.js (NVM + Node)
    run_installer "nvm.sh"

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

    run_installer "node.sh"
    run_installer "yarn.sh"
    run_installer "npm-packages.sh"

    # 4. Languages & Runtimes
    run_installer "go.sh"
    run_installer "gitego.sh"
    run_installer "python.sh"

    # 5. CLI Utilities
    run_installer "jq.sh"
    run_installer "tree.sh"
    run_installer "shellcheck.sh"
    run_installer "pandoc.sh"
    run_installer "tmux.sh"
    run_installer "vim.sh"
    run_installer "htop.sh"
    run_installer "rsync.sh"
    run_installer "nmap.sh"
    run_installer "imagemagick.sh"
    run_installer "yt-dlp.sh"

    # 6. Infrastructure & DevOps
    run_installer "docker.sh"
    run_installer "tailscale.sh"
    run_installer "aws-cli.sh"
    run_installer "certbot.sh"

    # 7. AI Tools
    run_installer "gemini-cli.sh"
    run_installer "claude-code.sh"

    # 8. Shell Configuration
    run_installer "shell-config.sh"

    # 9. Cleanup
    run_installer "apt-cleanup.sh"

    echo "Application installation complete."
}

apply_preferences() {
    local prefs_script="$PREFERENCES_DIR/setup.sh"

    if [ -f "$prefs_script" ]; then
        bash "$prefs_script"
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
