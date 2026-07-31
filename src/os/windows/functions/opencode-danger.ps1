# opencode-danger - Launch OpenCode CLI with automatic permission approval
#
# Uses OpenCode's documented --auto mode. Explicit deny rules still apply.
#
# Usage:
#   opencode-danger
#   opencode-danger "some prompt"

function opencode-danger {
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Write-Host "OpenCode is not currently installed."
        Write-Host "Install with: npm install -g opencode-ai"
        return
    }

    Write-Host "Launching OpenCode CLI with automatic permission approval..."
    opencode --auto @args
}
