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

Alternatively, if you have cloned the repository, you can run the setup script directly:

```bash
./src/setup.sh
```

### Windows (PowerShell)

*Setup instructions coming soon.* This will utilize a `src/setup.ps1` script to perform a similar initialization for Windows environments.
