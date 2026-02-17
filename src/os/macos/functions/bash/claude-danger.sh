#!/bin/bash
# claude-danger - Launch Claude CLI with dangerous mode
#
# Starts Claude CLI bypassing permission checks. Use with caution.
#
# Usage:
#   claude-danger
#   claude-danger "some prompt"
#   claude-danger 35e26140-96c5-470b-83e2-e00d8bd6a42f
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

    # If first argument is a session UUID, resume it
    if [[ "$1" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        echo "Resuming Claude session $1 in dangerous mode..."
        claude --resume "$1" --dangerously-skip-permissions
    else
        echo "Launching Claude CLI in dangerous mode (skipping permission checks)..."
        claude --dangerously-skip-permissions "$@"
    fi
}
