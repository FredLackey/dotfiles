#!/bin/bash
set -e

PREF_NAME="Git Preferences"
CHANGES_MADE=false

echo "Configuring $PREF_NAME..."

# Skip if git is not installed
if ! command -v git >/dev/null 2>&1; then
    echo "Git is not installed. Skipping Git preferences."
    exit 0
fi

# Helper: set a git config value only if it differs from desired
set_git_config() {
    local key="$1"
    local value="$2"

    local current
    current=$(git config --global "$key" 2>/dev/null || echo "__UNSET__")

    if [ "$current" = "$value" ]; then
        return
    fi

    git config --global "$key" "$value"
    CHANGES_MADE=true
}

# =============================================================================
# User Identity (only set if not already configured)
# =============================================================================

# Note: User name and email should be set manually or via environment
# These are left as prompts rather than hardcoded values

current_name=$(git config --global user.name 2>/dev/null || echo "")
current_email=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$current_name" ]; then
    echo "Warning: Git user.name is not set. Set it with: git config --global user.name 'Your Name'"
fi

if [ -z "$current_email" ]; then
    echo "Warning: Git user.email is not set. Set it with: git config --global user.email 'you@example.com'"
fi

# =============================================================================
# Core Settings
# =============================================================================

# Default branch name for new repos
set_git_config "init.defaultBranch" "main"

# Use VS Code as default editor (falls back to vim if not available)
if command -v code >/dev/null 2>&1; then
    set_git_config "core.editor" "code --wait"
elif command -v vim >/dev/null 2>&1; then
    set_git_config "core.editor" "vim"
fi

# Handle line endings (input = convert CRLF to LF on commit, leave LF alone on checkout)
set_git_config "core.autocrlf" "input"

# Prevent issues with file permission changes
set_git_config "core.fileMode" "false"

# Enable parallel index preload for faster status
set_git_config "core.preloadindex" "true"

# =============================================================================
# Color Settings
# =============================================================================

set_git_config "color.ui" "auto"
set_git_config "color.branch" "auto"
set_git_config "color.diff" "auto"
set_git_config "color.status" "auto"

# =============================================================================
# Push/Pull Behavior
# =============================================================================

# Push only the current branch by default
set_git_config "push.default" "current"

# Automatically set up remote tracking
set_git_config "push.autoSetupRemote" "true"

# Rebase instead of merge on pull
set_git_config "pull.rebase" "true"

# =============================================================================
# Diff and Merge
# =============================================================================

# Use histogram diff algorithm (better for code)
set_git_config "diff.algorithm" "histogram"

# Show original in merge conflicts
set_git_config "merge.conflictstyle" "diff3"

# =============================================================================
# Aliases
# =============================================================================

set_git_config "alias.st" "status"
set_git_config "alias.co" "checkout"
set_git_config "alias.br" "branch"
set_git_config "alias.ci" "commit"
set_git_config "alias.unstage" "reset HEAD --"
set_git_config "alias.last" "log -1 HEAD"
set_git_config "alias.lg" "log --oneline --graph --decorate --all"
set_git_config "alias.amend" "commit --amend --no-edit"

# =============================================================================
# Credential Helper
# =============================================================================

# Use cache credential helper (stores credentials in memory for 1 hour)
set_git_config "credential.helper" "cache --timeout=3600"

# =============================================================================
# Summary
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi
