#!/bin/bash
# git-push - Add, commit, and push in one command
#
# Usage:
#   git-push "Fix bug #123"
#
# Dependencies:
#   - git (brew install git)

git-push() {
    local usage="git-push \"commit message\""
    local message="$1"
    local current_branch
    local has_changes

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    # Check if a commit message was provided
    if [ -z "$message" ]; then
        echo "Error: Commit message is required"
        echo "Usage: $usage"
        return 1
    fi

    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Error: Not in a git repository"
        return 1
    fi

    # Check for any changes (staged, unstaged, or untracked files)
    has_changes=$(git status --porcelain)
    if [ -z "$has_changes" ]; then
        echo "No changes detected in repository"
        return 0
    fi

    # Get current branch name
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$current_branch" ]; then
        echo "Error: Could not determine current branch"
        return 1
    fi

    # Add all changes, commit with message, and push to current branch
    echo "Changes detected, proceeding with commit and push..."
    git add -A && \
    git commit -m "$message" && \
    git push origin "$current_branch"
}
