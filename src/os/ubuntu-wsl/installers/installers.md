# Ubuntu WSL Installers

This document lists all available installer scripts for Ubuntu WSL.

## Excluded vs Ubuntu Server

The following installers present in `ubuntu-server` are intentionally **not included** in `ubuntu-wsl`:

| Excluded Script | Reason |
|-----------------|--------|
| `docker.sh` | Docker Desktop on Windows provides Docker to WSL; Docker Engine is not installed |
| `tailscale.sh` | Windows handles networking and VPN |
| `nightshift.sh` | No desktop environment in WSL |

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
| `github-cli.sh` | GitHub CLI (gh) |
| `curl.sh` | Command-line HTTP client |
| `wget.sh` | File downloader |
| `gpg.sh` | GNU Privacy Guard |

## Shell Configuration

| Script | Description |
|--------|-------------|
| `shell-config.sh` | Deploy shell config files (.bashrc, .bash_profile, .tmux.conf, starship.toml) |
| `starship.sh` | Starship cross-shell prompt |
| `starship-config.sh` | Deploy starship.toml to ~/.config/starship.toml |

## Node.js & JavaScript

| Script | Description |
|--------|-------------|
| `nvm.sh` | Node Version Manager |
| `node.sh` | Node.js (via NVM, LTS) |
| `yarn.sh` | Yarn package manager |
| `npm-packages.sh` | Global npm packages (npm-check-updates) |

## Programming Languages

| Script | Description |
|--------|-------------|
| `go.sh` | Go programming language |
| `gitego.sh` | Gitego Git tool (requires Go) |
| `python.sh` | Python 3 with pip and venv |

## CLI Utilities

| Script | Description |
|--------|-------------|
| `jq.sh` | JSON processor |
| `tree.sh` | Directory tree viewer |
| `shellcheck.sh` | Shell script linter |
| `pandoc.sh` | Document converter (with LaTeX) |
| `tmux.sh` | Terminal multiplexer |
| `vim.sh` | Vim editor (GTK3 version) |
| `htop.sh` | Interactive process viewer |
| `rsync.sh` | Fast file transfer utility |
| `nmap.sh` | Network scanner |
| `imagemagick.sh` | Image manipulation toolkit |
| `ffmpeg.sh` | Audio/video processing |
| `bash-completion.sh` | Programmable bash completion |
| `yt-dlp.sh` | YouTube and video downloader |

## Infrastructure & DevOps

| Script | Description |
|--------|-------------|
| `aws-cli.sh` | AWS Command Line Interface |
| `tfenv.sh` | Terraform version manager |
| `terraform.sh` | Terraform (via TFEnv) |

## AI Tools

| Script | Description |
|--------|-------------|
| `claude-code.sh` | Claude Code CLI |

## Developer Tools

| Script | Description |
|--------|-------------|
| `td.sh` | td task management CLI (marcus/td) |
| `sidecar.sh` | Sidecar TUI (marcus/sidecar) |

## Installation Order

The `setup.sh` orchestrator runs installers in this order:

1. System prerequisites (apt-update, build-essential)
2. Core CLI tools (git, github-cli, curl, wget, gpg)
3. Shell configuration (shell-config, starship, starship-config)
4. Node.js stack (nvm, node, yarn, npm-packages)
5. Languages (go, gitego, python)
6. CLI utilities (jq, tree, shellcheck, pandoc, tmux, vim, htop, rsync, nmap, imagemagick, ffmpeg, bash-completion, yt-dlp)
7. Infrastructure (aws-cli, tfenv, terraform)
8. AI tools (claude-code)
9. Developer tools (td, sidecar)
10. Cleanup (apt-cleanup)

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
