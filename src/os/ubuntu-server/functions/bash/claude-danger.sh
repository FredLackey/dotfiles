#!/bin/bash
# Launch Claude CLI with dangerous mode bypassing permission checks.
#
# Usage:
#   claude-danger
#   claude-danger "some prompt"
#   claude-danger 35e26140-96c5-470b-83e2-e00d8bd6a42f

claude-danger() {
    if ! command -v claude >/dev/null 2>&1; then
        echo "Claude is not currently installed."
        echo "Please install Claude CLI to use this function."
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
