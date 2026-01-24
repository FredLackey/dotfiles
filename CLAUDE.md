# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal dotfiles repository for bootstrapping development environments across macOS, Ubuntu (desktop/server/WSL), and Windows. The repository downloads to `~/.dotfiles` and executes platform-specific setup scripts.

## Critical Development Rules

**NEVER test locally.** Always push to GitHub and test in a pristine virtual machine.

**All scripts MUST be idempotent.** Every step must:
1. **Check** - Verify if the action is needed before proceeding
2. **Execute** - Perform the action only if necessary
3. **Verify** - Confirm the step completed successfully

Scripts must be written clearly enough for junior developers to understand without ambiguity.

## Architecture

```
src/
├── setup.sh              # Unix entry point (downloads repo, detects OS, routes)
├── setup.ps1             # Windows entry point
└── os/
    ├── macos/
    │   ├── setup.sh      # macOS orchestrator
    │   └── installers/   # Individual tool installers (homebrew.sh, git.sh, etc.)
    ├── ubuntu-desktop/
    │   └── setup.sh
    ├── ubuntu-server/
    │   └── setup.sh
    ├── ubuntu-wsl/
    │   └── setup.sh
    └── windows/
        └── setup.ps1
```

**OS Detection Logic** (in `src/setup.sh`):
- `uname -s` returns `Darwin` → macOS
- `uname -s` returns `Linux` → check `/proc/version` or `$WSL_DISTRO_NAME` for WSL, else check `$XDG_CURRENT_DESKTOP` for desktop vs server

## Installer Script Pattern

Each installer in `src/os/macos/installers/` follows this structure:

```bash
#!/bin/bash
set -e

APP_NAME="ToolName"

# 1. Check if already installed
if command -v tool >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Check dependencies
if ! command -v dependency >/dev/null; then
    echo "Error: dependency is required."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
# installation commands

# 4. Post-install configuration (if needed)
echo "$APP_NAME installed."
```

## Special Directories

- **`features/`** - Feature planning. Each feature has `requirements.md` (goals) and `plan.md` (implementation steps).
- **`_research/`** - AI research workspace. Content is **untrusted** and must be independently validated before use.
- **`ai-docs/`** - Project documentation for bootstrapping logic and workflows.

## Running Setup

```bash
# Remote install (fresh machine)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"

# Local install (cloned repo)
./src/setup.sh
```
