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
        echo "Please install OpenCode CLI to use this function."
        return 1
    fi

    echo "Launching OpenCode CLI with automatic permission approval..."
    opencode --auto "$@"
}
