#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="$SCRIPT_DIR/installers"
PREFERENCES_DIR="$SCRIPT_DIR/preferences"

echo "Running macOS setup..."

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

    # 1. Critical System Tools (Order matters)
    run_installer "xcode-command-line-tools.sh"
    run_installer "homebrew.sh"
    
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

    run_installer "nvm.sh"
    run_installer "node.sh"

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

    # 2. Fonts & Prompt
    run_installer "nerd-fonts.sh"
    run_installer "starship.sh"
    run_installer "starship-config.sh"

    # 3. Core CLI Tools
    run_installer "git.sh"
    run_installer "bash-completion.sh"
    run_installer "wget.sh"
    run_installer "gpg.sh"

    # 4. Languages & Runtimes
    run_installer "yarn.sh"
    run_installer "npm-check-updates.sh"
    run_installer "go.sh"
    run_installer "tfenv.sh"
    run_installer "terraform.sh"

    # 5. CLI Tools
    run_installer "jq.sh"
    run_installer "yq.sh"
    run_installer "tree.sh"
    run_installer "shellcheck.sh"
    run_installer "pandoc.sh"
    run_installer "ffmpeg.sh"
    run_installer "yt-dlp.sh"
    run_installer "imagemagick.sh"
    run_installer "nmap.sh"
    run_installer "tmux.sh"
    run_installer "vim.sh"
    run_installer "gemini-cli.sh"
    run_installer "claude-code.sh"
    run_installer "aws-cli.sh"
    
    # 6. Applications & GUI Tools
    
    run_installer "vscode.sh"
    run_installer "cursor.sh"
    run_installer "sublime-text.sh"

    run_installer "docker.sh"
    run_installer "postman.sh"
    run_installer "dbeaver.sh"
    run_installer "studio-3t.sh"
    run_installer "drawio.sh"
    run_installer "slack.sh"
    run_installer "termius.sh"
    run_installer "appcleaner.sh"
    run_installer "caffeine.sh"
    run_installer "moom.sh"
    run_installer "balena-etcher.sh"
    run_installer "beyond-compare.sh"
    run_installer "superwhisper.sh"
    run_installer "keyboard-maestro.sh"
    
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
