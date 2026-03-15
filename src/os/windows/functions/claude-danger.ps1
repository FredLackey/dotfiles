# claude-danger - Launch Claude CLI with dangerous mode (skips permission checks)
#
# Usage:
#   claude-danger
#   claude-danger "some prompt"
#   claude-danger 35e26140-96c5-470b-83e2-e00d8bd6a42f

function claude-danger {
    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "Claude is not currently installed."
        Write-Host "Install with: winget install Anthropic.ClaudeCode"
        return
    }

    $uuidPattern = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    if ($args.Count -gt 0 -and $args[0] -match $uuidPattern) {
        Write-Host "Resuming Claude session $($args[0]) in dangerous mode..."
        claude --resume $args[0] --dangerously-skip-permissions
    } else {
        Write-Host "Launching Claude CLI in dangerous mode (skipping permission checks)..."
        claude --dangerously-skip-permissions @args
    }
}
