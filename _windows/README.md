# Windows Development Environment Setup

Simplified PowerShell script for setting up a Windows development machine with essential tools. This is a standalone approach that does not alter the main dotfiles repository (which focuses on macOS and Linux).

## Goals

- Single PowerShell script for quick Windows dev machine setup
- Install core development tools via Chocolatey
- No shell customization (Bash aliases/functions are not applicable)
- No symlinks or dotfile management
- Minimal, opinionated, and fast
- Target: Windows 11+

---

## Decisions

| Decision | Choice |
|----------|--------|
| Package Manager | **Chocolatey** |
| Node Version Manager | **nvm-windows** |
| Editor (Vim-like) | **NeoVim** |
| Primary Editor | **VSCode** |
| Build Tools | **Visual Studio Build Tools** (required) |
| Browser | **Google Chrome** |
| Terminal | **Windows Terminal** (if not present) |
| GPG | **Gpg4win** (GPG + pinentry for commit signing) |
| Git Identity Management | **gitego** (via `go install`) |
| VPN | **Tailscale** |
| Git Configuration | Skip (manual post-install) |

---

## Comparison: Main Dotfiles vs Windows

### Package Manager

| Main Dotfiles | Windows |
|---------------|---------|
| Homebrew (macOS) | Chocolatey |
| APT (Ubuntu) | Chocolatey |

### Core Development Tools

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **Git** | `brew install git` / `apt install git` | Git for Windows (includes Git Bash) | INSTALL |
| **Node.js (via NVM)** | `nvm` (cloned from GitHub) | nvm-windows | INSTALL |
| **Node 22** | Installed via nvm | Installed via nvm-windows | INSTALL |
| **Yarn** | APT package | `npm install -g yarn` | INSTALL |
| **Go** | Not in main dotfiles | Chocolatey | INSTALL |
| **Docker** | docker-ce via APT | N/A (see note below) | EXCLUDED |
| **cURL** | APT package | Built into Windows / Git Bash | BUILT-IN |
| **jq** | Homebrew | Chocolatey | INSTALL |
| **yq** | Homebrew | Chocolatey | INSTALL |

### Editors & IDEs

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **Vim** | `brew install vim` | NeoVim | INSTALL |
| **VSCode** | Not in main dotfiles | Chocolatey | INSTALL |

### Shell & Terminal

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **Bash** | Default shell (configured extensively) | Git Bash (bundled with Git) | INSTALL |
| **Windows Terminal** | N/A | Chocolatey (if not present) | INSTALL |
| **tmux** | `brew install tmux` | Not native; WSL required | SKIP |
| **bash_aliases** | Extensive customization | N/A | N/A |
| **bash_functions** | Extensive customization | N/A | N/A |
| **bash_prompt** | Custom prompt | N/A | N/A |
| **bash_exports** | Environment variables | Set via PowerShell/System | N/A |

### Security & Signing

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **GPG** | `brew install gpg` | Gpg4win | INSTALL |
| **pinentry** | pinentry-mac | Included in Gpg4win | INSTALL |
| **gitego** | Git identity management | `go install` | INSTALL |

### Build Tools

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **build-essential** | gcc, make, etc. | Visual Studio Build Tools | INSTALL |
| **debian-archive-keyring** | APT signing | N/A | N/A |

### Browser

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **Google Chrome** | Homebrew cask | Chocolatey | INSTALL |

### Utilities

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| **tree** | APT package | Built into Windows | BUILT-IN |
| **Tailscale** | VPN | Chocolatey | INSTALL |
| **ShellCheck** | Linting for shell scripts | Chocolatey | OPTIONAL |
| **Pandoc** | Document conversion | Chocolatey | OPTIONAL |
| **LaTeX** | texlive | MiKTeX or TeX Live | OPTIONAL |

### Graphics/Media Tools (Excluded)

| Tool | Main Dotfiles | Windows | Status |
|------|---------------|---------|--------|
| VLC | Homebrew cask | N/A | EXCLUDED |
| Image tools | Various | N/A | EXCLUDED |
| Video tools | Various | N/A | EXCLUDED |
| Web font tools | Various | N/A | EXCLUDED |

---

## Installation Plan

### Package Manager: Chocolatey

Chocolatey will be installed first if not already present. All subsequent installs use `choco install`.

### Installation Order

1. **Chocolatey** (if not installed)
2. **Windows Terminal** (if not present)
3. **Git for Windows** (includes Git Bash)
4. **nvm-windows** (Node Version Manager)
5. **Node.js 22** (via nvm)
6. **Yarn** (via npm)
7. **Go**
8. **gitego** (via `go install`, requires Go)
9. **NeoVim**
10. **VSCode**
11. **jq / yq** (JSON/YAML processors)
12. **Visual Studio Build Tools**
13. **Google Chrome**
14. **Gpg4win** (GPG + pinentry)
15. **Tailscale** (VPN)

### Script Structure

```powershell
# setup.ps1 - Windows Development Environment Setup
# Run as Administrator: powershell -ExecutionPolicy Bypass -File setup.ps1

# 1. Check prerequisites (admin rights, Windows version)
# 2. Install Chocolatey (if not present)
# 3. Install Windows Terminal (if not present)
# 4. Install Git for Windows
# 5. Install nvm-windows
# 6. Install Node.js 22 via nvm
# 7. Install global npm packages (yarn)
# 8. Install Go
# 9. Install gitego (go install github.com/bgreenwell/gitego@main)
# 10. Install NeoVim
# 11. Install VSCode
# 12. Install jq, yq
# 13. Install Visual Studio Build Tools
# 14. Install Google Chrome
# 15. Install Gpg4win
# 16. Install Tailscale
# 17. Add Go bin to PATH (%USERPROFILE%\go\bin)
# 18. Display post-installation summary
```

---

## What We WILL Install

| Category | Tools |
|----------|-------|
| **Package Manager** | Chocolatey |
| **Terminal** | Windows Terminal |
| **Version Control** | Git for Windows (with Git Bash) |
| **Node.js** | nvm-windows, Node 22, Yarn |
| **Go** | Go (system-level) |
| **Editors** | NeoVim, Visual Studio Code |
| **Utilities** | jq, yq |
| **Build Tools** | Visual Studio Build Tools |
| **Security** | Gpg4win (GPG + pinentry for commit signing) |
| **Git Identity** | gitego (manage multiple Git identities) |
| **VPN** | Tailscale |
| **Browser** | Google Chrome |

## What We WILL NOT Install

| Category | Reason |
|----------|--------|
| **Docker / Containers** | Requires WSL2 or Hyper-V, which need nested virtualization in a Proxmox VM. Run containers on a separate Linux VM instead. |
| **Bash configuration** | Git Bash provides Bash, but extensive customization isn't practical |
| **tmux** | Requires WSL; not native to Windows |
| **Custom prompt** | PowerShell/Git Bash prompts are separate ecosystems |
| **Shell aliases/functions** | Would require porting to PowerShell; out of scope |
| **Graphics/media tools** | Excluded per requirements |
| **Symbolic links to dotfiles** | Not applicable; this is standalone |

## Prerequisites / Notes

- **Visual Studio Build Tools** is a large download (~2GB)
- Script must be run as Administrator
- Target environment: Windows 11 VM in Proxmox (no nested virtualization)
- **Go bin path** (`%USERPROFILE%\go\bin`) must be added to PATH for gitego

---

## Usage

```powershell
# Download and run
irm https://raw.github.com/fredlackey/dotfiles/main/_windows/setup.ps1 | iex

# Or clone and run locally
git clone https://github.com/fredlackey/dotfiles.git
cd dotfiles\_windows
.\setup.ps1

# Non-interactive mode (skip confirmation prompt)
.\setup.ps1 -SkipConfirmation
```

## Post-Installation

1. Restart PowerShell (or your terminal)
2. Run `nvm use 22` to activate Node.js
3. Configure Git identity:
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "you@email.com"
   ```
4. Configure gitego profiles (see `gitego --help`)
5. Import GPG keys and configure commit signing if needed
6. Log in to Tailscale: `tailscale up`

---

## Chocolatey Package Names Reference

| Tool | Chocolatey Package |
|------|-------------------|
| Git for Windows | `git` |
| nvm-windows | `nvm` |
| Go | `golang` |
| NeoVim | `neovim` |
| VSCode | `vscode` |
| jq | `jq` |
| yq | `yq` |
| Visual Studio Build Tools | `visualstudio2022buildtools` |
| Google Chrome | `googlechrome` |
| Windows Terminal | `microsoft-windows-terminal` |
| Gpg4win | `gpg4win` |
| Tailscale | `tailscale` |

## Non-Chocolatey Installs

| Tool | Install Command |
|------|-----------------|
| Node.js 22 | `nvm install 22` (via nvm-windows) |
| Yarn | `npm install -g yarn` |
| gitego | `go install github.com/bgreenwell/gitego@main` |
