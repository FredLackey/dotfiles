#!/bin/bash
# claude-danger - Launch Claude CLI with dangerous mode
#
# Starts Claude CLI bypassing permission checks. Use with caution.
#
# Usage:
#   claude-danger
#   claude-danger "some prompt"
#
# Dependencies:
#   - claude (npm install -g @anthropic-ai/claude-code)

claude-danger() {
    # Check if claude command is available
    if ! command -v claude &> /dev/null; then
        echo "Claude is not currently installed."
        echo "Install with: npm install -g @anthropic-ai/claude-code"
        return 1
    fi

    echo "Launching Claude CLI in dangerous mode (skipping permission checks)..."
    claude --dangerously-skip-permissions "$@"
}
