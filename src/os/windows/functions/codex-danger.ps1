# codex-danger - Launch Codex CLI in full-auto mode
#
# Usage:
#   codex-danger
#   codex-danger "some prompt"

function codex-danger {
    if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
        Write-Host "Codex is not currently installed."
        Write-Host "Install with: npm install -g @openai/codex"
        return
    }

    Write-Host "Launching Codex CLI in full-auto mode (skipping approval prompts)..."
    codex --full-auto @args
}
