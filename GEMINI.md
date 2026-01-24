# Gemini Context: Dotfiles

This `GEMINI.md` file provides essential context for the Gemini CLI agent when working with this dotfiles repository.

## Project Overview

This repository automates the bootstrapping and configuration of development environments across multiple operating systems. It is designed to be modular, idempotent, and easy to understand.

*   **Primary Goal:** One-command setup for a fresh machine.
*   **Supported OS:** macOS, Ubuntu (Desktop/Server/WSL), Windows.
*   **Key Technologies:** Bash (Unix), PowerShell (Windows).

## Architecture & Directory Structure

```text
/
├── .gitignore
├── CLAUDE.md              # Project guidelines (READ THIS FIRST)
├── README.md              # User-facing documentation
├── _research/             # AI scratchpad (untrusted code)
├── ai-docs/               # Documentation for AI/bootstrapping
├── features/              # Feature planning (requirements & plans)
└── src/
    ├── setup.ps1          # Windows entry point
    ├── setup.sh           # Unix entry point (OS detection & routing)
    └── os/                # OS-specific logic
        ├── macos/
        │   ├── setup.sh     # Orchestrator for macOS
        │   ├── files/       # Dotfiles to be copied (.zshrc, etc.)
        │   ├── installers/  # Individual, idempotent installer scripts
        │   └── preferences/ # macOS system preference scripts
        ├── ubuntu-desktop/
        ├── ubuntu-server/
        ├── ubuntu-wsl/
        └── windows/
```

### Execution Flow (Unix)

1.  **Entry:** User runs `src/setup.sh` (or curls it).
2.  **Detection:** Script detects OS (Darwin/Linux) and Sub-OS (Desktop/Server/WSL).
3.  **Routing:** Control is passed to `src/os/<platform>/setup.sh`.
4.  **Orchestration:** Platform script calls individual installers from `installers/` and applies preferences.

## Development Guidelines

### 1. Critical Rules (Strict Adherence Required)

*   **Idempotency is King:** Every script must follow the **Check -> Execute -> Verify** pattern.
    *   *Check:* Is the tool already installed? If yes, exit 0.
    *   *Execute:* Install the tool.
    *   *Verify:* Check if the installation was successful.
*   **No Local Testing:** Do not run unfinished scripts on the local host. Use a VM or container.
*   **Junior-Dev Readable:** Code must be simple, clear, and unambiguous. Avoid complex one-liners where a few lines of clear logic would suffice.

### 2. Adding a New Installer (macOS Example)

To add a new tool (e.g., `foo`):

1.  Create `src/os/macos/installers/foo.sh`.
2.  Implement the idempotency pattern (see below).
3.  Register the script in `src/os/macos/setup.sh` inside the `install_applications` function.

**Installer Template:**
```bash
#!/bin/bash
set -e

APP_NAME="Foo Tool"

# 1. Check
if command -v foo >/dev/null; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Prerequisites (optional)
if ! command -v brew >/dev/null; then
    echo "Error: Homebrew is required."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."
brew install foo

# 4. Verify
if command -v foo >/dev/null; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
```

## Common Tasks

*   **Update System Preferences:** Edit scripts in `src/os/macos/preferences/`.
*   **Add Shell Function:** Add to `src/os/macos/functions/` (ensure it's sourced in `.zshrc` or `.bash_profile`).
*   **Feature Planning:** Check `features/` for active feature branches or requirements.

## Testing
*   **Manual:** Push changes to GitHub, then run the curl command in a fresh VM/container.
*   **Local:** `./src/setup.sh` can be run if you are *certain* it won't break the current environment (mainly for logic checks, not heavy installs).
