# Dotfiles

Personal dotfiles for bootstrapping development environments across macOS, Ubuntu, and Windows. The repo downloads to `~/.dotfiles` and runs platform-specific setup scripts that are idempotent — safe to run multiple times on the same machine.

## OS Variant Status

| Variant | Status | Package Manager | Notes |
|---|---|---|---|
| **macOS** | Active | Homebrew | Full GUI + CLI toolchain, Zsh, Starship |
| **Windows** | Active | winget | PowerShell, WSL, GUI apps, writes log to Desktop |
| **Ubuntu WSL** | Active | apt | Runs inside Windows WSL2, writes log to Windows Desktop |
| **Ubuntu Server** | Active | apt | Headless server toolchain, Docker, Tailscale |
| **Ubuntu Desktop** | Placeholder | — | Stub only, not yet implemented |

## How It Works

The entry point (`src/setup.sh` for Unix, `src/setup.ps1` for Windows) clones the repo to `~/.dotfiles`, detects the OS, and delegates to the appropriate setup script under `src/os/`.

**OS detection order (Unix):**
1. `uname -s` returns `Darwin` → macOS
2. `WSL_DISTRO_NAME` is set or `/proc/version` contains "Microsoft" → Ubuntu WSL
3. `XDG_CURRENT_DESKTOP` is set → Ubuntu Desktop
4. Otherwise → Ubuntu Server

Each OS folder is completely self-contained. No cross-references between OS folders exist by design — duplication is intentional.

## Installation

### macOS

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"
```

### Ubuntu Server / Ubuntu WSL

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"
```

When running inside WSL, a timestamped log file is automatically written to the Windows Desktop:
`dotfiles-wsl-YYYY-MM-DD_HH-MM-SS.log`

### Windows (PowerShell — run as Administrator)

```powershell
iex (iwr -useb "https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.ps1").Content
```

A timestamped log file is written to the Desktop:
`dotfiles-setup-YYYY-MM-DD_HH-MM-SS.log`

> **Note:** winget ships with Windows 10 1809+ and Windows 11. If it is missing, install **App Installer** from the Microsoft Store first.

### Re-running after initial install

```bash
# Unix
~/.dotfiles/src/setup.sh

# Windows (PowerShell)
~\.dotfiles\src\setup.ps1
```

## Excluding Categories

Installers are grouped into categories. Pass `DOTFILES_EXCLUDE` to skip one or more:

```bash
# Unix
DOTFILES_EXCLUDE="AI,MEDIA" sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"

# Windows (PowerShell)
$env:DOTFILES_EXCLUDE="AI,MEDIA"; iex (iwr -useb "https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.ps1").Content
```

| Category | Contents |
|---|---|
| `SYSTEM` | Package manager updates, build tools, shell config |
| `LANGUAGES` | Node.js (NVM), Go, Python |
| `DEV` | Git, GitHub CLI, shellcheck, vim, dev utilities |
| `DEVOPS` | AWS CLI, Terraform, TFEnv, Docker |
| `UTILS` | curl, wget, jq, yq, tree, tmux, rsync, pandoc, htop |
| `MEDIA` | ffmpeg, ImageMagick, yt-dlp |
| `SECURITY` | nmap, gpg |
| `AI` | Claude Code, Gemini CLI |
| `APPS` | td, sidecar, and other developer tooling |
| `DESKTOP` | GUI applications (macOS and Windows only) |

## What Gets Installed

### macOS
Homebrew, Xcode CLI tools, Git, GitHub CLI, NVM, Node.js, Yarn, Go, Python, Starship, iTerm2, VS Code, Cursor, Docker, AWS CLI, Terraform, Claude Code, Gemini CLI, and a full suite of GUI apps (Slack, Chrome, Obsidian, etc.).

### Windows
Git, GitHub CLI, NVM, Node.js, Yarn, Go, AWS CLI, Terraform, Docker Desktop, VS Code, Cursor, Claude Code, Gemini CLI, and GUI apps (Slack, Chrome, Brave, DBeaver, etc.) via winget. Also configures PowerShell profile, Starship prompt, and WSL.

### Ubuntu WSL
Build essentials, Git, GitHub CLI, curl, wget, gpg, Starship, NVM, Node.js, Yarn, Go, Python, AWS CLI (arch-aware: x86\_64 or aarch64), Terraform, Claude Code, jq, yq, tree, shellcheck, pandoc, tmux, vim, htop, rsync, nmap, ImageMagick, ffmpeg, yt-dlp, td, sidecar. WSL-specific: configures `/etc/wsl.conf`, writes log to Windows Desktop.

### Ubuntu Server
Same core CLI toolchain as WSL plus Docker, Tailscale, and nightshift. No Starship or WSL-specific configuration.

## Logging

| Platform | Log location |
|---|---|
| Windows | `%USERPROFILE%\Desktop\dotfiles-setup-<timestamp>.log` |
| Ubuntu WSL | `%USERPROFILE%\Desktop\dotfiles-wsl-<timestamp>.log` (via `wslpath`) |
| macOS / Ubuntu Server | No log file — output goes to terminal |

Logs capture full verbose output from all installers. The terminal shows only high-level status lines.

## Architecture

```
src/
├── setup.sh              # Unix entry point (detects OS, delegates)
├── setup.ps1             # Windows entry point
└── os/
    ├── macos/
    │   ├── setup.sh
    │   ├── files/        # Shell dotfiles, configs, themes
    │   ├── functions/    # Custom shell functions (bash + zsh)
    │   ├── installers/   # One script per tool
    │   └── preferences/  # System preference scripts
    ├── windows/
    │   ├── setup.ps1
    │   ├── files/
    │   ├── functions/
    │   ├── installers/
    │   └── preferences/
    ├── ubuntu-wsl/
    │   ├── setup.sh
    │   ├── files/
    │   ├── functions/
    │   ├── installers/
    │   └── preferences/
    ├── ubuntu-server/
    │   ├── setup.sh
    │   ├── files/
    │   ├── functions/
    │   ├── installers/
    │   └── preferences/
    └── ubuntu-desktop/   # Placeholder — not yet implemented
        └── setup.sh
```

Each installer follows a four-step idempotent pattern:

```bash
# 1. CHECK   — skip if already installed
# 2. DEPS    — verify prerequisites
# 3. INSTALL — perform installation
# 4. VERIFY  — confirm success
```
