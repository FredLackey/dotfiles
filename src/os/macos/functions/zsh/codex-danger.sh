#!/bin/zsh
# codex-danger - Launch Codex CLI in full-auto mode
#
# Starts Codex CLI bypassing approval prompts. Use with caution.
#
# Usage:
#   codex-danger
#   codex-danger "some prompt"
#
# Dependencies:
#   - codex (npm install -g @openai/codex)

codex-danger() {
    # Check if codex command is available
    if ! command -v codex &> /dev/null; then
        echo "Codex is not currently installed."
        echo "Install with: npm install -g @openai/codex"
        return 1
    fi

    echo "Launching Codex CLI in full-auto mode (skipping approval prompts)..."
    codex --full-auto "$@"
}
