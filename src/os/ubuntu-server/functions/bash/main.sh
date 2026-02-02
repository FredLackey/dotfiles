#!/bin/bash
# Bash functions loader for Ubuntu Server
# Usage (add to .bashrc or .bash_profile):
#   source ~/.dotfiles/src/os/ubuntu-server/functions/bash/main.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if a category is excluded via DOTFILES_EXCLUDE environment variable
# Usage: _dotfiles_is_excluded "AI" returns 0 (true) if excluded, 1 (false) if not
_dotfiles_is_excluded() {
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

# Conditionally source a function file based on category
# Usage: _dotfiles_source "filename.sh" "CATEGORY"
_dotfiles_source() {
    local file="$1"
    local category="$2"
    if [ -n "$category" ] && _dotfiles_is_excluded "$category"; then
        return 0
    fi
    if [ -f "$SCRIPT_DIR/$file" ]; then
        source "$SCRIPT_DIR/$file"
    fi
}

# Categories: DEV, DEVOPS, UTILS, MEDIA, AI

# Git & Repository Management
_dotfiles_source "clone.sh" "DEV"
_dotfiles_source "git-clone.sh" "DEV"
_dotfiles_source "git-pup.sh" "DEV"
_dotfiles_source "git-push.sh" "DEV"
_dotfiles_source "git-backup.sh" "DEV"
_dotfiles_source "set-git-public.sh" "DEV"
_dotfiles_source "fetch-github-repos.sh" "DEV"
_dotfiles_source "vpush.sh" "DEV"

# Docker
_dotfiles_source "docker-clean.sh" "DEVOPS"

# File Management
_dotfiles_source "delete-files.sh" "UTILS"
_dotfiles_source "org-by-date.sh" "UTILS"
_dotfiles_source "rename-files-with-date-in-name.sh" "UTILS"
_dotfiles_source "resize-image.sh" "MEDIA"
_dotfiles_source "get-folder.sh" "UTILS"
_dotfiles_source "refresh-files.sh" "UTILS"
_dotfiles_source "remove-smaller-files.sh" "UTILS"
_dotfiles_source "rm-safe.sh" "UTILS"

# Media & Downloads
_dotfiles_source "get-tunes.sh" "MEDIA"
_dotfiles_source "get-video.sh" "MEDIA"
_dotfiles_source "get-course.sh" "MEDIA"
_dotfiles_source "get-channel.sh" "MEDIA"

# Development
_dotfiles_source "clean-dev.sh" "DEV"
_dotfiles_source "npmi.sh" "DEV"
_dotfiles_source "killni.sh" "DEV"
_dotfiles_source "get-dependencies.sh" "DEV"
_dotfiles_source "install-dependencies-from.sh" "DEV"
_dotfiles_source "ncu-update-all.sh" "DEV"
_dotfiles_source "datauri.sh" "UTILS"
_dotfiles_source "evm.sh" "DEV"

# System & Backup
_dotfiles_source "backup-source.sh" "UTILS"
_dotfiles_source "backup-all.sh" "UTILS"
_dotfiles_source "ips.sh" "UTILS"

# Search & History
_dotfiles_source "h.sh" "UTILS"
_dotfiles_source "s.sh" "UTILS"

# Utilities
_dotfiles_source "ccurl.sh" "UTILS"
_dotfiles_source "mkd.sh" "UTILS"

# Nginx & SSL
_dotfiles_source "nginx-init.sh" "DEVOPS"
_dotfiles_source "certbot-init.sh" "DEVOPS"
_dotfiles_source "certbot-crontab-init.sh" "DEVOPS"

# AI Tools
_dotfiles_source "claude-danger.sh" "AI"
