#!/bin/bash
# Launch Claude CLI with dangerous mode bypassing permission checks.
#
# Usage:
#   claude-danger

claude-danger() {
    if command -v claude >/dev/null 2>&1; then
        echo "Launching Claude CLI in dangerous mode (skipping permission checks)..."
        claude --dangerously-skip-permissions "$@"
    else
        echo "Claude is not currently installed."
        echo "Please install Claude CLI to use this function."
        return 1
    fi
}
