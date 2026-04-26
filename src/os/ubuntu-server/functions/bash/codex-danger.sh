#!/bin/bash
# codex-danger - Launch Codex CLI in YOLO mode
#
# Starts Codex CLI bypassing approval prompts and sandboxing. Use with caution.
#
# Usage:
#   codex-danger
#   codex-danger <session-id-or-name>
#   codex-danger <session-id-or-name> "follow-up prompt"
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

    if [ "$#" -eq 0 ]; then
        echo "Launching Codex CLI in YOLO mode..."
        codex --yolo
    else
        echo "Resuming Codex CLI in YOLO mode..."
        codex resume --yolo "$@"
    fi
}
