#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$SCRIPT_DIR/installers"
PREFERENCES_DIR="$SCRIPT_DIR/preferences"

echo "Running macOS setup..."

# Suppress automatic cleanup after each brew install (runs once at the end instead)
export HOMEBREW_NO_INSTALL_CLEANUP=1

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
        bash "$script_path"
    else
        echo "Error: Installer script not found: $script_name"
        exit 1
    fi
}

install_applications() {
    echo "Starting application installation..."

    # Categories: SYSTEM, LANGUAGES, TERMINAL, DEV, DEVOPS, UTILS, MEDIA, SECURITY, AI, APPS

    # 1. Critical System Tools (Order matters)
    run_installer "xcode-command-line-tools.sh" "SYSTEM"
    run_installer "homebrew.sh" "SYSTEM"

    # Reload Path for Homebrew (required for subsequent steps)
    if ! command -v brew >/dev/null; then
        echo "Loading Homebrew environment..."
        if [ -x "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -x "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        # Verify load
        if command -v brew >/dev/null; then
            echo "Homebrew loaded into memory."
        else
            echo "Warning: Failed to load Homebrew into memory. Subsequent installs may fail."
        fi
    fi

    run_installer "nvm.sh" "LANGUAGES"
    run_installer "node.sh" "LANGUAGES"

    # Reload NVM environment (required for npm-dependent installers)
    if ! command -v npm >/dev/null; then
        echo "Loading NVM environment..."
        export NVM_DIR="$HOME/.nvm"
        if command -v brew >/dev/null; then
            BREW_PREFIX=$(brew --prefix)
            if [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ]; then
                . "$BREW_PREFIX/opt/nvm/nvm.sh"
            fi
        fi
        if [ -s "$NVM_DIR/nvm.sh" ]; then
            . "$NVM_DIR/nvm.sh"
        fi

        if command -v npm >/dev/null; then
            echo "NVM loaded into memory."
        else
            echo "Warning: Failed to load NVM into memory. npm-dependent installs may fail."
        fi
    fi

    # 2. Shell Configuration (core - always install)
    run_installer "shell-config.sh" "SYSTEM"

    # 3. Fonts & Prompt (cosmetic enhancements)
    run_installer "nerd-fonts.sh" "TERMINAL"
    run_installer "starship.sh" "TERMINAL"
    run_installer "starship-config.sh" "TERMINAL"
    run_installer "shell-cosmetics.sh" "TERMINAL"

    # 4. Core CLI Tools
    run_installer "git.sh" "DEV"
    run_installer "github-cli.sh" "DEV"
    run_installer "bash-completion.sh" "UTILS"
    run_installer "wget.sh" "UTILS"
    run_installer "gpg.sh" "UTILS"

    # 4. Languages & Runtimes
    run_installer "yarn.sh" "LANGUAGES"
    run_installer "npm-check-updates.sh" "LANGUAGES"
    run_installer "go.sh" "LANGUAGES"
    run_installer "tfenv.sh" "DEVOPS"
    run_installer "terraform.sh" "DEVOPS"

    # 5. CLI Tools
    run_installer "web-font-tools.sh" "DEV"
    run_installer "jq.sh" "UTILS"
    run_installer "yq.sh" "UTILS"
    run_installer "tree.sh" "UTILS"
    run_installer "shellcheck.sh" "DEV"
    run_installer "pandoc.sh" "UTILS"
    run_installer "basictex.sh" "UTILS"
    run_installer "ffmpeg.sh" "MEDIA"
    run_installer "yt-dlp.sh" "MEDIA"
    run_installer "imagemagick.sh" "MEDIA"
    run_installer "nmap.sh" "SECURITY"
    run_installer "tmux.sh" "UTILS"
    run_installer "vim.sh" "DEV"
    run_installer "gemini-cli.sh" "AI"
    run_installer "claude-code.sh" "AI"
    run_installer "aws-cli.sh" "DEVOPS"

    # 7. Applications & GUI Tools
    run_installer "iterm2.sh" "APPS"
    run_installer "vscode.sh" "DEV"
    run_installer "cursor.sh" "AI"
    run_installer "sublime-text.sh" "DEV"

    run_installer "docker.sh" "DEVOPS"
    run_installer "postman.sh" "DEV"
    run_installer "dbeaver.sh" "DEV"
    run_installer "studio-3t.sh" "DEV"
    run_installer "drawio.sh" "DEV"
    run_installer "slack.sh" "APPS"
    run_installer "termius.sh" "APPS"
    run_installer "appcleaner.sh" "APPS"
    run_installer "caffeine.sh" "APPS"
    run_installer "moom.sh" "APPS"
    run_installer "balena-etcher.sh" "APPS"
    run_installer "beyond-compare.sh" "DEV"
    run_installer "google-chrome.sh" "APPS"
    run_installer "superwhisper.sh" "APPS"
    run_installer "keyboard-maestro.sh" "APPS"

    # 8. Marcus Developer Tools (td must be first — other tools reference it)
    run_installer "td.sh" "APPS"
    run_installer "sidecar.sh" "APPS"
    run_installer "nightshift.sh" "APPS"
    run_installer "betamax.sh" "APPS"

    # Final cleanup (runs once instead of after every install)
    echo "Running brew cleanup..."
    brew cleanup --quiet

    echo "Application installation complete."
}

apply_preferences() {
    local prefs_script="$PREFERENCES_DIR/setup.sh"

    if [ -f "$prefs_script" ]; then
        bash "$prefs_script"
    else
        echo "Error: Preferences setup script not found: $prefs_script"
        exit 1
    fi
}

# Execute installation
install_applications

# Apply system preferences
apply_preferences

echo ""
echo "Setup complete. Open a new terminal window to activate the new shell configuration."
