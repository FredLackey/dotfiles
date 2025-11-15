# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository that manages shell configurations, Git settings, and development environment setup across multiple platforms (macOS, Ubuntu variants, Raspberry Pi OS). The repository is designed to be self-installing and maintains a modular structure with OS-specific configurations.

## Architecture

### Directory Structure

- **`src/`** - Core dotfiles and installation scripts
  - **`src/shell/`** - Bash configuration files (aliases, functions, exports, prompts)
    - Contains OS-specific subdirectories: `macos/`, `ubuntu-*/`, `raspberry-pi-os/`
    - Main files are sourced first, then OS-specific overrides are loaded via `$OS` variable
  - **`src/git/`** - Git configuration files (`gitconfig`, `gitignore`, `gitattributes`)
  - **`src/vim/`** - Vim configuration and plugins
  - **`src/tmux/`** - tmux configuration
  - **`src/bin/`** - Custom executable scripts
  - **`src/os/`** - Operating system setup and configuration scripts
    - **`src/os/installs/`** - Software installation scripts by OS
    - **`src/os/preferences/`** - System preference configuration scripts
    - `setup.sh` - Main setup orchestrator
    - `create_symbolic_links.sh` - Links dotfiles to home directory
    - `create_local_config_files.sh` - Creates `.local` files for customization
    - `utils.sh` - Shared utility functions used across all scripts

- **`scripts/`** - Development and maintenance scripts
  - `lint/` - Code quality tools (shellcheck, markdownlint)
  - `check_links/` - Link validation utilities
  - `utils/` - Helper scripts for maintenance

- **`_simplified/`** - Standalone installation scripts without helper functions
  - Provides direct, minimal scripts for quick installations
  - Alternative approach for users who want transparency over abstraction

- **`templates/`** - Configuration templates (nginx, etc.)
- **`ai-docs/`** - AI-generated documentation for aliases and functions

### Key Design Patterns

1. **OS Detection and Routing**: The `get_os_name()` function returns values like `macos`, `ubuntu-24-svr`, `ubuntu-24-wks`, etc. Scripts use this to load OS-specific configurations.

2. **Layered Configuration**:
   - Base configuration files in `src/shell/`
   - OS-specific overrides in `src/shell/$OS/`
   - User customizations in `~/.*.local` files (never committed)

3. **Symbolic Linking**: Setup creates symlinks from `~/.bashrc`, `~/.gitconfig`, etc. to files in this repository, enabling version control while maintaining standard locations.

4. **Local Customization**: Files ending in `.local` (e.g., `~/.bash.local`, `~/.gitconfig.local`) are automatically sourced/included but never committed, allowing machine-specific configurations.

5. **Utility Function Pattern**: All setup scripts source `src/os/utils.sh` which provides:
   - `execute()` - Run commands with output formatting
   - `print_*()` functions for colored output
   - `ask_for_confirmation()` - Interactive prompts
   - `cmd_exists()` - Check if command is available
   - `get_os()` / `get_os_name()` - OS detection

## Common Commands

### Setup and Installation

```bash
# Full setup (interactive)
bash -c "$(curl -LsS https://raw.github.com/fredlackey/dotfiles/main/src/os/setup.sh)"

# Non-interactive mode (for CI/CD)
./src/os/setup.sh -y
# or
./src/os/setup.sh --yes

# Update existing installation
cd ~/projects/dotfiles/src/os && ./setup.sh
```

### Linting and Testing

```bash
# Lint all shell scripts
./scripts/lint/shell.sh

# Lint all markdown files
./scripts/lint/markdown.sh
```

### Working with OS-Specific Files

When editing shell configurations:
1. Check if an OS-specific file exists in `src/shell/$OS/`
2. If it exists, that file overrides the base configuration
3. For cross-platform changes, modify the base file in `src/shell/`
4. For OS-specific behavior, modify the OS-specific file

The `$OS` variable is set by `bash_init` and points to the appropriate OS-specific directory.

## Setup Script Flow

The `src/os/setup.sh` orchestrates the following sequence:

1. **OS Verification** - Checks OS type and version compatibility
2. **Download dotfiles** - If not run locally, downloads and extracts from GitHub
3. **Create symbolic links** - Links dotfiles to home directory
4. **Create local config files** - Sets up `.local` files for customization
5. **Install software** - Runs OS-specific installation scripts
6. **Configure preferences** - Applies OS-specific system preferences
7. **Initialize Git repository** - Sets up Git remote (workstation environments only)
8. **Restart prompt** - Offers to restart system (interactive mode)

## Important Files

- **`src/shell/bash_aliases`** - Command aliases, including Terraform shortcuts (`tpo`, `tpa`) and safe `rm` override
- **`src/shell/bash_functions`** - Extensive function library (Docker helpers, Git utilities, file operations)
- **`src/shell/bash_exports`** - Environment variables and PATH configuration
- **`src/shell/bash_prompt`** - Customized prompt configuration
- **`src/os/utils.sh`** - Shared utility functions - source this at the beginning of any new setup script
- **`src/os/create_symbolic_links.sh`** - Defines which files get symlinked to home directory

## OS-Specific Variants

The repository supports multiple Ubuntu variants with specific configurations:

- **macOS** - Full desktop environment with GUI apps
- **ubuntu-24-wks** - Ubuntu 24 workstation (desktop)
- **ubuntu-24-svr** - Ubuntu 24 server (no GUI)
- **ubuntu-23-svr**, **ubuntu-22-svr**, **ubuntu-20-svr** - Legacy Ubuntu server versions
- **raspberry-pi-os** - Raspberry Pi OS (Debian-based)

When adding new functionality, consider whether it should be platform-specific or universal.

## Modifying Configurations

### Adding New Shell Functions

1. Add function to `src/shell/bash_functions` (or OS-specific variant)
2. Functions are auto-loaded by `bash_profile` → `bashrc` → `bash_functions` chain
3. Test by sourcing: `source ~/.bashrc`

### Adding New Aliases

1. Add to `src/shell/bash_aliases` (or OS-specific variant)
2. Terraform aliases already exist: `tpo` (plan with output) and `tpa` (apply from plan)
3. Test by sourcing: `source ~/.bash.local`

### Adding Software to Install

1. Add installation script to appropriate `src/os/installs/$OS/` directory
2. Source it from `src/os/installs/$OS/main.sh`
3. Use utility functions: `brew_install`, `execute "command" "Description"`

## Style Guidelines

### Shell Scripts

- Use shellcheck for linting (exclusions: SC1090, SC1091, SC2155, SC2164)
- Source `utils.sh` at the beginning: `cd "$(dirname "${BASH_SOURCE[0]}")" && . "../utils.sh"`
- Use `execute` function for commands that should be logged
- Use `print_*` functions for consistent output formatting
- Make scripts executable: `chmod +x script.sh`

### File Naming

- Shell config files: lowercase with underscores (e.g., `bash_functions`)
- Install scripts: lowercase with underscores and `.sh` extension
- OS-specific directories: lowercase with hyphens (e.g., `ubuntu-24-svr`)

## Git Workflow

- Main branch: `main`
- Repository uses Git LFS for binary files (see `.gitattributes`)
- Never commit `.local` files - they're in `.gitignore`
- CI/CD runs on both macOS and Ubuntu via GitHub Actions
