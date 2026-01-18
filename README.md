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

## Critical Development Rules

These guidelines are absolute and must be followed for all scripts and documentation.

1.  **Idempotency**: All scripts must be idempotent.
    -   **Check**: Each step must verify if the action is needed before proceeding.
    -   **Execute**: Perform the action only if necessary.
    -   **Verify**: Confirm that the step was completed successfully after execution.

2.  **Accessibility**: All scripts and documentation must be written clearly and simply, ensuring that a junior developer can understand and implement the plan without ambiguity.

## Feature Planning

The `features/` directory accounts for requirements and plans related to upcoming features or major changes.

- Each feature resides in its own dedicated subfolder (e.g., `features/new-feature-name/`).
- **requirements.md**: This file captures the specific requirements and goals for the feature.
- **plan.md**: Created after requirements are finalized, this file details the implementation steps.

## Research & experimentation

The `_research/` directory is a designated area for placing assets used by AI for research on privately known topics.

- **Purpose**: A workspace for AI analysis, experiment artifacts, and temporary context.
- **Untrusted**: Content in this folder is **not** to be trusted, copied from, or used purely as-is. It may contain invalid code, failed experiments, or raw data.
- **Validation Required**: We must conduct our own independent research and verification. Any insights gained from this folder must be validated before being implemented in the main codebase.


