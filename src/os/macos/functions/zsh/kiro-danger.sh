#!/bin/zsh
# kiro-danger - Launch Kiro CLI chat with all tools trusted
#
# Starts Kiro CLI chat bypassing tool approval prompts. Use with caution.
#
# Usage:
#   kiro-danger
#   kiro-danger <resume-id>
#
# Dependencies:
#   - kiro-cli (https://kiro.dev)

kiro-danger() {
    # Check if kiro-cli command is available
    if ! command -v kiro-cli &> /dev/null; then
        echo "Kiro CLI is not currently installed."
        echo "Install from: https://kiro.dev"
        return 1
    fi

    # If an argument is provided, resume that chat session
    if [ -n "$1" ]; then
        echo "Resuming Kiro chat $1 with all tools trusted..."
        kiro-cli chat --v3 --trust-all-tools --resume-id "$1"
    else
        echo "Launching Kiro chat with all tools trusted..."
        kiro-cli chat --v3 --trust-all-tools
    fi
}
