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

*Setup instructions coming soon.* This will utilize a `src/setup.ps1` script to perform a similar initialization for Windows environments.

