# Installed application inventory — 2026-09-13

This inventory follows the active setup orchestrators and lists software installed by a default run. It includes command-line tools, runtimes, fonts, and desktop applications. It omits configuration-only steps, preference changes, package-index updates, cleanup tasks, and transitive dependencies. Any category named in `DOTFILES_EXCLUDE` is skipped.

## macOS

### System and package management

- Xcode Command Line Tools
- Homebrew

### Languages and package tools

- Node.js 26 (with npm)
- Bun
- Yarn
- npm-check-updates
- Go

### Terminal and fonts

- Bash Completion
- Starship
- iTerm2
- Ghostty
- tmux
- Meslo LG Nerd Font
- Fira Code Nerd Font
- JetBrains Mono Nerd Font

### Development

- Git
- GitHub CLI
- Atlassian CLI (`acli`)
- ShellCheck
- Vim
- Visual Studio Code
- Sublime Text
- Postman
- DBeaver Community
- Studio 3T
- draw.io
- Beyond Compare
- Web Font Tools
  - `sfnt2woff-zopfli`
  - `sfnt2woff`
  - `woff2`

### AI tools

- Gemini CLI
- Claude Code
- OpenCode CLI
- Herdr
- Kiro
- Kiro CLI
- Cursor
- Codex

### Infrastructure and cloud

- tfenv
- Terraform
- AWS CLI
- Google Cloud CLI
- saml2aws
- Docker Desktop
- Podman

### Utilities, media, and security

- Wget
- GnuPG
- jq
- yq
- Tree
- Pandoc
- BasicTeX
- FFmpeg
- yt-dlp
- ImageMagick
- Nmap

### Desktop applications

- Slack
- Termius
- AppCleaner
- Caffeine
- Moom
- balenaEtcher
- Google Chrome
- Superwhisper
- Telegram
- Obsidian

### Retired

These installers remain registered in the macOS orchestrator under the always-skipped `RETIRED` category:

- Brave Browser
- Keyboard Maestro
- Adobe Acrobat Pro
- UTM
- Google Chrome Canary

## Ubuntu Desktop

- No applications are installed. The current setup only applies keyboard preferences.

## Ubuntu Server

### System and build tools

- Build Essential

### Languages and package tools

- Node.js 26 (with npm)
- Yarn
- npm-check-updates
- Go
- Python 3
- pip
- Python `venv`

### Development

- Git
- GitHub CLI
- Atlassian CLI (`acli`)
- ShellCheck
- Vim

### AI tools

- Claude Code
- OpenCode CLI
- Herdr
- Kiro CLI

### Infrastructure and cloud

- Docker Engine
- Docker CLI
- containerd
- Docker Buildx
- Docker Compose
- Podman
- Tailscale
- AWS CLI
- Google Cloud CLI
- saml2aws
- tfenv
- Terraform

### Utilities, media, and security

- curl
- Wget
- GnuPG
- jq
- yq
- Tree
- Pandoc
- tmux
- htop
- rsync
- Nmap
- ImageMagick
- FFmpeg
- Bash Completion
- yt-dlp

## Ubuntu WSL

### System and build tools

- Build Essential

### Languages and package tools

- Node.js 26 (with npm)
- Yarn
- npm-check-updates
- Go
- Python 3
- pip
- Python `venv`

### Terminal

- Starship

### Development

- Git
- GitHub CLI
- Atlassian CLI (`acli`)
- ShellCheck
- Vim

### AI tools

- Claude Code
- OpenCode CLI
- Herdr
- Kiro CLI

### Infrastructure and cloud

- AWS CLI
- Google Cloud CLI
- saml2aws
- tfenv
- Terraform
- Podman

### Utilities, media, and security

- curl
- Wget
- GnuPG
- jq
- yq
- Tree
- Pandoc
- tmux
- htop
- rsync
- Nmap
- ImageMagick
- FFmpeg
- Bash Completion
- yt-dlp

## Windows

### System

- Windows Subsystem for Linux
- Ubuntu for WSL

### Languages and package tools

- Node.js 26 (with npm)
- Bun
- Yarn
- npm-check-updates
- Go

### Terminal and fonts

- Starship
- MesloLGS NF
- Fira Code Nerd Font
- JetBrains Mono Nerd Font

### Development

- Git
- GitHub CLI
- Visual Studio Code
- Sublime Text
- Postman
- DBeaver
- Studio 3T
- draw.io
- Beyond Compare

### AI tools

- Gemini CLI
- Claude Code
- OpenCode CLI
- Cursor
- Kiro

### Infrastructure and cloud

- Terraform
- AWS CLI
- Docker Desktop

### Utilities, media, and security

- Gpg4win
- jq
- yq
- Pandoc
- SharpKeys
- yt-dlp
- ImageMagick
- Nmap

### Desktop applications

- Slack
- Google Chrome
- Obsidian
- Telegram
- Termius
- balenaEtcher

### Retired

These installers remain registered in the Windows orchestrator under the always-skipped `RETIRED` category:

- Brave Browser
