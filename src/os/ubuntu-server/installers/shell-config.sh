#!/bin/bash
set -e

APP_NAME="Shell Configuration"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$SCRIPT_DIR/../files"
DOTFILES_DIR="$HOME/.dotfiles"

# 1. Check if already up to date
check_symlink() {
    local source="$1"
    local target="$2"
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        [ "$current_target" = "$source" ]
    else
        return 1
    fi
}

BASHRC_CURRENT=false
BASH_PROFILE_CURRENT=false

if check_symlink "$FILES_DIR/.bashrc" "$HOME/.bashrc"; then
    BASHRC_CURRENT=true
fi

if check_symlink "$FILES_DIR/.bash_profile" "$HOME/.bash_profile"; then
    BASH_PROFILE_CURRENT=true
fi

if [ "$BASHRC_CURRENT" = true ] && [ "$BASH_PROFILE_CURRENT" = true ]; then
    echo "$APP_NAME is already up to date."
    exit 0
fi

echo "Installing $APP_NAME..."

# Backup and symlink function
backup_and_link() {
    local source="$1"
    local target="$2"
    local filename=$(basename "$target")

    # Skip if source doesn't exist
    if [ ! -f "$source" ]; then
        echo "Warning: Source file not found: $source"
        return 0
    fi

    # Check if symlink already points to correct location
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo "$filename is already linked correctly."
            return 0
        fi
        # Symlink exists but points elsewhere, remove it
        rm "$target"
    fi

    # Backup existing file if it exists and is not a symlink
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi

    # Create symlink
    echo "Linking $filename"
    ln -s "$source" "$target"
}

# Link shell configuration files
backup_and_link "$FILES_DIR/.bashrc" "$HOME/.bashrc"
backup_and_link "$FILES_DIR/.bash_profile" "$HOME/.bash_profile"

# Create .inputrc symlink if it exists
if [ -f "$FILES_DIR/.inputrc" ]; then
    backup_and_link "$FILES_DIR/.inputrc" "$HOME/.inputrc"
fi

# Create .bash.local if it doesn't exist (for local customizations)
if [ ! -f "$HOME/.bash.local" ]; then
    echo "Creating ~/.bash.local for local customizations..."
    cat > "$HOME/.bash.local" << 'EOF'
#!/bin/bash
# ~/.bash.local - Local bash customizations
# This file is sourced by .bash_profile and is not tracked by git.
# Add your machine-specific settings here.

EOF
fi

echo "$APP_NAME installed successfully."
