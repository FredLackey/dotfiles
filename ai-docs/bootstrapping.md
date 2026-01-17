# Setup Script Logic (`setup.sh`)

This document outlines the logic and requirements for the root `setup.sh` script. This script is the entry point for bootstrapping the dotfiles configuration on a new machine.

## detailed Workflow

1.  **Define Variables**
    *   Repo URL: `https://github.com/FredLackey/dotfiles/archive/refs/heads/main.zip`
    *   Target Directory: `~/.dotfiles`
    *   Temp Directory: A temporary location for the download.

2.  **Download & Extract**
    *   Download the repository zip file from GitHub.
    *   Unzip the content.
    *   Move/Install the files into `~/.dotfiles`.
    *   Ensure the script is running from the new location or can reference it.

3.  **OS/Environment Detection**
    The script must detect the current operating system to delegate to the correct specific setup script in `src/`.

    *   **macOS (Darwin)**
        *   Target Script: `src/setup_macos.sh`
    *   **Ubuntu / WSL**
        *   Check if it is a Desktop, Server, or WSL environment.
        *   Target Script (General/Server): `src/setup_ubuntu-server.sh`
        *   Target Script (Desktop): `src/setup_ubuntu-desktop.sh`
        *   Target Script (WSL): `src/setup_ubuntu-wsl.sh`
    *   **Windows**
        *   *Note: Windows native setup will likely start via `setup.ps1`.*

4.  **Execution**
    *   Make the target script executable (`chmod +x`).
    *   Execute the target script.

## Directory Structure Reference

The repository structure used by this logic:

```text
/
├── setup.sh                  # Entry point (Download wrapper)
├── setup.ps1                 # Entry point for Windows PowerShell
├── ai-docs/                  # Documentation
│   └── bootstrapping.md      # This file
└── src/                      # Environment-specific scripts
    ├── setup_macos.sh
    ├── setup_ubuntu-server.sh
    ├── setup_ubuntu-desktop.sh
    ├── setup_ubuntu-wsl.sh
    └── setup_windows.ps1
```

## Plan

### File Responsibilities

*   **`setup.sh`**:
    *   Acts as the universal entry point for POSIX systems (Linux/macOS).
    *   Downloads and extracts the repository to `~/.dotfiles` (idempotently; checks if exists before overwriting).
    *   Detects the operating system.
    *   Delegates execution to the specific `src/` script.
*   **`setup.ps1`**:
    *   Acts as the entry point for Windows systems.
    *   Downloads and extracts the repository to `$HOME\.dotfiles`.
    *   Executes `src/setup_windows.ps1`.
*   **`src/setup_macos.sh`**:
    *   Handles macOS-specific configuration (Homebrew, Zsh, macOS defaults).
*   **`src/setup_ubuntu-server.sh`**:
    *   Handles headless Ubuntu configuration (APT packages, basic shell setup).
*   **`src/setup_ubuntu-desktop.sh`**:
    *   Extends server setup with desktop environments (GNOME/KDE tweaks, GUI apps).
*   **`src/setup_ubuntu-wsl.sh`**:
    *   Handles WSL-specific integrations (Windows interoperability, WSL conf).
*   **`src/setup_windows.ps1`**:
    *   Handles Windows native configuration (Winget, PowerShell profile).

### Utilities & Tools

The bootstrapping process will minimize external dependencies to ensure it runs on a fresh machine.

*   **Base Dependencies (Must exist universally or be checked first)**:
    *   `curl` (or `wget`): For downloading the repository.
    *   `unzip`: For extracting the archive.
    *   `mkdir`, `mv`, `chmod`: Basic file operations.
    *   `grep`, `cat`: Text parsing for OS detection.
*   **Idempotency Tools**:
    *   `command -v`: To check for existing tools before installation.
    *   `test -f` / `test -d`: To check for existing files/directories.

### OS Detection Strategy

For `setup.sh`, the following logic will determine the target environment:

1.  **Check `uname -s`**:
    *   Returns `Darwin` -> Execute `src/setup_macos.sh`.
    *   Returns `Linux` -> Proceed to Linux sub-checks.
2.  **Linux Sub-Environment Checks**:
    *   **WSL Check**: Look for "Microsoft" or "WSL" in `/proc/version` or check if `$WSL_DISTRO_NAME` is set.
        *   If detected -> Execute `src/setup_ubuntu-wsl.sh`.
    *   **Desktop Check**: Check for GUI-related variables (e.g., `$XDG_CURRENT_DESKTOP`) or availability of display servers (X11/Wayland).
        *   If detected -> Execute `src/setup_ubuntu-desktop.sh`.
    *   **Server/Default**:
        *   If neither WSL nor Desktop is detected -> Execute `src/setup_ubuntu-server.sh`.
