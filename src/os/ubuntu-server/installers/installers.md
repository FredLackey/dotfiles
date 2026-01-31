# Ubuntu Server Installers

This document lists all available installer scripts for Ubuntu Server.

## System Prerequisites

| Script | Description |
|--------|-------------|
| `apt-update.sh` | Update and upgrade apt packages |
| `apt-cleanup.sh` | Clean up unused packages and cache |
| `build-essential.sh` | C/C++ compiler and build tools |

## Core CLI Tools

| Script | Description |
|--------|-------------|
| `git.sh` | Git version control |
| `curl.sh` | Command-line HTTP client |

## Node.js & JavaScript

| Script | Description |
|--------|-------------|
| `nvm.sh` | Node Version Manager |
| `node.sh` | Node.js (via NVM, v22) |
| `yarn.sh` | Yarn package manager |
| `npm-packages.sh` | Global npm packages (npm-check-updates) |

## Programming Languages

| Script | Description |
|--------|-------------|
| `go.sh` | Go programming language |
| `gitego.sh` | Gitego Git tool (requires Go) |

## CLI Utilities

| Script | Description |
|--------|-------------|
| `jq.sh` | JSON processor |
| `tree.sh` | Directory tree viewer |
| `shellcheck.sh` | Shell script linter |
| `pandoc.sh` | Document converter (with LaTeX) |
| `tmux.sh` | Terminal multiplexer |
| `vim.sh` | Vim editor (GTK3 version) |

## Infrastructure & DevOps

| Script | Description |
|--------|-------------|
| `docker.sh` | Docker Engine (CE) with Compose |
| `tailscale.sh` | Tailscale VPN |

## AI Tools

| Script | Description |
|--------|-------------|
| `gemini-cli.sh` | Google Gemini CLI |
| `claude-code.sh` | Claude Code CLI |

## Shell Configuration

| Script | Description |
|--------|-------------|
| `shell-config.sh` | Deploy shell config files (.bashrc, .bash_profile) |

## Installation Order

The `setup.sh` orchestrator runs installers in this order:

1. System prerequisites (apt-update, build-essential)
2. Core CLI tools (git, curl)
3. Node.js stack (nvm, node, yarn, npm-packages)
4. Languages (go, gitego)
5. CLI utilities (jq, tree, shellcheck, pandoc, tmux, vim)
6. Infrastructure (docker, tailscale)
7. AI tools (gemini-cli, claude-code)
8. Shell configuration
9. Cleanup (apt-cleanup)

## Creating New Installers

All installers must follow the idempotent pattern:

```bash
#!/bin/bash
set -e

APP_NAME="ToolName"

# 1. CHECK - Skip if already installed
if command -v tool >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v required-tool >/dev/null 2>&1; then
    echo "Error: required-tool is required but not installed."
    exit 1
fi

# 3. INSTALL - Perform the installation
echo "Installing $APP_NAME..."
# installation commands here

# 4. VERIFY - Confirm installation succeeded
if command -v tool >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
```
