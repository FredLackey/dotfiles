# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for setting up development environments across macOS, Ubuntu (multiple versions), and Raspberry Pi OS. It includes shell configurations, Git settings, Vim/tmux configurations, and automated installation scripts.

## Key Commands

### Linting and Testing
```bash
# Lint shell scripts
./scripts/lint/shell.sh

# Lint markdown files
./scripts/lint/markdown.sh

# Check links in markdown
./scripts/check_links/markdown.sh
```

### Setup and Installation
```bash
# Interactive setup (DO NOT run in CI/CD)
./src/os/setup.sh

# Non-interactive setup (use -y flag)
./src/os/setup.sh -y

# CI/CD specific setup
./src/os/setup-cicd.sh

# Recreate symbolic links only
./src/os/create_symbolic_links.sh

# Run OS-specific installations
./src/os/installs/main.sh

# Set OS preferences
./src/os/preferences/main.sh
```

## Architecture

### Multi-OS Shell Configuration System

The repository uses a sophisticated **OS-specific configuration overlay system** for shell files:

1. **Base Configuration**: `src/shell/bash_*` files contain shared functions/aliases/settings
2. **OS-Specific Overlays**: Directories like `src/shell/macos/`, `src/shell/ubuntu-24-wks/`, `src/shell/ubuntu-22-svr/`, etc.
3. **Symlink Logic**: `src/os/create_symbolic_links.sh` determines which shell files to symlink based on OS detection
4. **Sourcing Pattern**: OS-specific shell files source the main `bash_functions` via `~/.bash_functions_main` symlink

**Critical**: When modifying shell configurations:
- OS-specific files should source the main bash_functions: `. "$HOME/.bash_functions_main"`
- Changes to base shell files affect ALL environments
- OS-specific files override or extend base configurations
- The `get_os_name()` function in `src/os/utils.sh` determines which overlay to use

### Directory Structure

```
src/
├── bin/           # Custom executable scripts
├── git/           # Git configurations (gitconfig, gitignore, gitattributes)
├── os/
│   ├── installs/  # OS-specific installation scripts
│   │   ├── macos/
│   │   ├── ubuntu-{20,22,23,24}-svr/  # Server variants
│   │   ├── ubuntu-24-wks/              # Workstation variant
│   │   ├── ubuntu-original/
│   │   └── raspberry-pi-os/
│   ├── preferences/  # OS-specific preference scripts
│   ├── setup.sh      # Main setup orchestrator
│   ├── setup-cicd.sh # CI/CD non-interactive setup
│   ├── create_symbolic_links.sh  # Symlink manager
│   └── utils.sh      # Shared utility functions
├── shell/         # Base shell configurations
│   ├── bash_aliases, bash_exports, bash_functions, bash_prompt, etc.
│   └── {os-name}/  # OS-specific shell overlays
├── tmux/          # tmux configurations
└── vim/           # Vim configurations and plugins
```

### OS Detection and Naming

The `get_os_name()` function in `src/os/utils.sh` returns specific OS identifiers:
- `macos` - macOS systems
- `ubuntu-{version}-svr` - Ubuntu server (20, 22, 23, 24)
- `ubuntu-{version}-wks` - Ubuntu workstation
- `raspberry-pi-os` - Raspberry Pi OS

Environment differentiation (server vs workstation) can be controlled via the `DOTFILES_ENV` environment variable.

### Installation Script Pattern

Each OS has a `main.sh` that orchestrates installations of:
- build-essentials.sh
- git.sh
- browsers.sh
- compression_tools.sh
- image_tools.sh
- misc_tools.sh
- tmux.sh
- vim.sh
- utils.sh
- cleanup.sh

### Utility Functions (src/os/utils.sh)

Key functions for shell scripts:
- `get_os()` - Returns OS identifier (macos, ubuntu, raspbian)
- `get_os_name()` - Returns specific OS variant (e.g., ubuntu-24-wks)
- `get_os_version()` - Returns OS version
- `cmd_exists()` - Check if command exists
- `execute()` - Run command with spinner and success/error feedback
- `print_*()` - Colored output functions (print_success, print_error, print_warning, etc.)
- `ask_for_confirmation()` - Interactive yes/no prompts
- `skip_questions()` - Check for -y/--yes flags

## ShellCheck Configuration

The linting script (`scripts/lint/shell.sh`) excludes:
- SC1090: Can't follow non-constant source
- SC1091: Not following sourced files
- SC2155: Declare and assign separately
- SC2164: Use cd ... || exit in case cd fails

## Local Customization

Users can extend configurations with:
- `~/.bash.local` - Sourced after all bash configs
- `~/.gitconfig.local` - Included in gitconfig for credentials
- `~/.vimrc.local` - Sourced after vimrc

**Never commit these `.local` files.**

## GitHub Actions CI/CD

Workflows test on both macOS and Ubuntu:
- Lint shell scripts with ShellCheck
- Lint markdown files
- Check links in markdown
- Run on every push

## Forking Considerations

When forking this repository:
- Update `GITHUB_REPOSITORY` variable in `src/os/setup.sh` (line 15)
- Update setup snippet URLs in README.md
- Update `setup-cicd.sh` SETUP_URL

## Development Guidelines

1. **Shell Scripts**: Follow existing patterns from `utils.sh` for consistency
2. **OS-Specific Code**: Place in appropriate `{os-name}/` subdirectory
3. **Cross-Platform Functions**: Add to base `src/shell/bash_functions`
4. **Testing**: Run linting scripts before committing
5. **Symlinks**: Understand that `create_symbolic_links.sh` manages all dotfile symlinks to `$HOME`
6. **Server vs Workstation**: Server environments skip git repository initialization and certain GUI tools
- **IMPORTANT**: NEVER test scripts on the local machine.  After every change they are manually tested on a new VM.