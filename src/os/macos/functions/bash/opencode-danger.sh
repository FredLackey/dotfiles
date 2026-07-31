#!/bin/bash
# opencode-danger - Launch OpenCode CLI with automatic permission approval
#
# Uses OpenCode's documented --auto mode. Explicit deny rules still apply.
#
# Usage:
#   opencode-danger
#   opencode-danger "some prompt"

opencode-danger() {
    if ! command -v opencode >/dev/null 2>&1; then
        echo "OpenCode is not currently installed."
        echo "Install with: npm install -g opencode-ai"
        return 1
    fi

    echo "Launching OpenCode CLI with automatic permission approval..."
    opencode --auto "$@"
}
