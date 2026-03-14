# Dotfiles

This repository contains my personal configuration files (dotfiles) for setting up a new development environment. It is designed to work across multiple operating systems including macOS, Ubuntu, and Windows.

## Overview

- **macOS**: Focus on Zsh.
- **Ubuntu**: Targeted for both hosting environments and desktop use.
- **Windows**: Support for PowerShell and WSL.

## Installation

### macOS & Ubuntu (Bash/Zsh)

To install, simply open your terminal and run the following command. This script will download the repository to `~/.dotfiles`, setup the environment, and execute the appropriate configuration scripts for your OS.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"
```

To exclude specific categories (e.g., AI tools and terminal customizations):

```bash
DOTFILES_EXCLUDE="AI,TERMINAL" sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"
```

Available categories: `SYSTEM`, `LANGUAGES`, `TERMINAL`, `DEV`, `DEVOPS`, `UTILS`, `MEDIA`, `SECURITY`, `AI`, `APPS`, `DESKTOP`

Alternatively, if you have already installed (or cloned) the repository, you can re-run the setup script locally:

```bash
~/.dotfiles/src/setup.sh
```

To re-run locally with exclusions:

```bash
DOTFILES_EXCLUDE="AI,TERMINAL" ~/.dotfiles/src/setup.sh
```

### Windows (PowerShell)

Open PowerShell as Administrator and run:

```powershell
iex (iwr -useb "https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.ps1").Content
```

This downloads the repository to `~\.dotfiles`, detects Windows, and runs the Windows-specific setup using **winget** as the package manager.

To exclude specific categories (e.g., AI tools and terminal customizations):

```powershell
$env:DOTFILES_EXCLUDE="AI,TERMINAL"; iex (iwr -useb "https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.ps1").Content
```

Available categories: `SYSTEM`, `LANGUAGES`, `TERMINAL`, `DEV`, `DEVOPS`, `UTILS`, `MEDIA`, `SECURITY`, `AI`, `APPS`, `DESKTOP`

Alternatively, if you have already installed the repository, you can re-run locally:

```powershell
~\.dotfiles\src\setup.ps1
```

> **Note:** winget ships with Windows 10 1809+ and Windows 11. If it is not present, install **App Installer** from the Microsoft Store before running setup.

