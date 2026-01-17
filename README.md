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
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/setup.sh)"
```

### Windows (PowerShell)

*Setup instructions coming soon.* This will utilize a `setup.ps1` script to perform a similar initialization for Windows environments.

## Critical Development Rules

These guidelines are absolute and must be followed for all scripts and documentation.

1.  **Idempotency**: All scripts must be idempotent.
    -   **Check**: Each step must verify if the action is needed before proceeding.
    -   **Execute**: Perform the action only if necessary.
    -   **Verify**: Confirm that the step was completed successfully after execution.

2.  **Accessibility**: All scripts and documentation must be written clearly and simply, ensuring that a junior developer can understand and implement the plan without ambiguity.
