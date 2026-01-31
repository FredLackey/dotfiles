#!/bin/bash
# Bash functions loader for Ubuntu Server
# Usage (add to .bashrc or .bash_profile):
#   source ~/.dotfiles/src/os/ubuntu-server/functions/bash/main.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Git & Repository Management
source "$SCRIPT_DIR/clone.sh"
source "$SCRIPT_DIR/git-clone.sh"
source "$SCRIPT_DIR/git-pup.sh"
source "$SCRIPT_DIR/git-push.sh"
source "$SCRIPT_DIR/git-backup.sh"
source "$SCRIPT_DIR/set-git-public.sh"
source "$SCRIPT_DIR/fetch-github-repos.sh"
source "$SCRIPT_DIR/vpush.sh"

# Docker
source "$SCRIPT_DIR/docker-clean.sh"

# File Management
source "$SCRIPT_DIR/delete-files.sh"
source "$SCRIPT_DIR/org-by-date.sh"
source "$SCRIPT_DIR/rename-files-with-date-in-name.sh"
source "$SCRIPT_DIR/resize-image.sh"
source "$SCRIPT_DIR/get-folder.sh"
source "$SCRIPT_DIR/refresh-files.sh"
source "$SCRIPT_DIR/remove-smaller-files.sh"
source "$SCRIPT_DIR/rm-safe.sh"

# Media & Downloads
source "$SCRIPT_DIR/get-tunes.sh"
source "$SCRIPT_DIR/get-video.sh"
source "$SCRIPT_DIR/get-course.sh"
source "$SCRIPT_DIR/get-channel.sh"

# Development
source "$SCRIPT_DIR/clean-dev.sh"
source "$SCRIPT_DIR/npmi.sh"
source "$SCRIPT_DIR/killni.sh"
source "$SCRIPT_DIR/get-dependencies.sh"
source "$SCRIPT_DIR/install-dependencies-from.sh"
source "$SCRIPT_DIR/ncu-update-all.sh"
source "$SCRIPT_DIR/datauri.sh"
source "$SCRIPT_DIR/evm.sh"

# System & Backup
source "$SCRIPT_DIR/backup-source.sh"
source "$SCRIPT_DIR/backup-all.sh"
source "$SCRIPT_DIR/ips.sh"

# Search & History
source "$SCRIPT_DIR/h.sh"
source "$SCRIPT_DIR/s.sh"

# Utilities
source "$SCRIPT_DIR/ccurl.sh"
source "$SCRIPT_DIR/mkd.sh"

# Nginx & SSL
source "$SCRIPT_DIR/nginx-init.sh"
source "$SCRIPT_DIR/certbot-init.sh"
source "$SCRIPT_DIR/certbot-crontab-init.sh"

# AI Tools
source "$SCRIPT_DIR/claude-danger.sh"
