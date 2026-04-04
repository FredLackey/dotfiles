# Atlassian CLI (ACLI) - macOS Installation

## Overview

| Field | Value |
|---|---|
| Tool Name | Atlassian CLI (`acli`) |
| Publisher | Atlassian Labs |
| Description | Official command-line interface for interacting with Atlassian Cloud products (Jira, Confluence, Rovo Dev) from the terminal |
| macOS Available | Yes |
| Current Version | 1.3.17-stable (as of April 2026) |
| Official Docs | https://developer.atlassian.com/cloud/acli/reference/commands/ |
| Install Guide | https://developer.atlassian.com/cloud/acli/guides/install-macos/ |
| Homebrew Formula | `atlassian-labs/acli/acli` (third-party tap from `atlassian/homebrew-acli`) |

## Supported Products

- Jira Cloud (projects, boards, sprints, work items, filters, dashboards, fields)
- Confluence Cloud
- Atlassian Admin (user and auth management)
- Rovo Dev (Atlassian's AI coding agent, beta)

## Prerequisites

- macOS (Intel or Apple Silicon)
- Homebrew (recommended) or `curl` for manual install
- An Atlassian Cloud account with access to the products you want to manage

No additional runtime dependencies are required. ACLI ships as a standalone binary.

## Installation

### Option 1: Homebrew (Recommended)

```bash
# Add the Atlassian tap
brew tap atlassian/homebrew-acli

# Install ACLI
brew install acli
```

To update later:

```bash
brew upgrade acli
```

### Option 2: Direct Binary Download

For Apple Silicon (M1/M2/M3/M4):

```bash
curl -LO "https://acli.atlassian.com/darwin/latest/acli_darwin_arm64/acli"
chmod +x ./acli
sudo mv ./acli /usr/local/bin/acli
sudo chown root: /usr/local/bin/acli
```

For Intel Macs:

```bash
curl -LO "https://acli.atlassian.com/darwin/latest/acli_darwin_amd64/acli"
chmod +x ./acli
sudo mv ./acli /usr/local/bin/acli
sudo chown root: /usr/local/bin/acli
```

## Verification

```bash
acli --version
```

Expected output (version number will vary):

```
acli version 1.3.17-stable
```

Also confirm the binary location:

```bash
which acli
```

Should return `/opt/homebrew/bin/acli` (Homebrew) or `/usr/local/bin/acli` (manual).

## Authentication

ACLI uses OAuth for authentication. It opens a browser window to complete the login flow.

### Login

```bash
acli auth login
```

This opens your default browser to the Atlassian OAuth consent screen. Grant access and the CLI stores the token locally.

### Check Auth Status

```bash
acli auth status
```

### Switch Between Accounts

If you have multiple Atlassian Cloud accounts:

```bash
acli auth switch
```

### Logout

```bash
acli auth logout
```

## Post-Install Configuration

### Shell Completion (Optional)

Generate shell completions for your shell:

```bash
# For zsh (add to ~/.zshrc)
acli completion zsh > "${fpath[1]}/_acli"

# For bash
acli completion bash > /opt/homebrew/etc/bash_completion.d/acli
```

### Government Cloud

If you need to connect to Atlassian Government Cloud instead of standard Cloud:

```bash
acli config gov-cloud --help
```

## Quick Start: Common Jira Commands

Once authenticated, here are some useful commands:

```bash
# List projects
acli jira project list

# Search work items (issues)
acli jira workitem search --query "project = PROJ AND status = 'In Progress'"

# View a specific work item
acli jira workitem view PROJ-123

# List boards
acli jira board search

# List sprints for a board
acli jira board list-sprints --board-id 42
```

Use `acli jira --help` to see all available Jira subcommands.

## Notes

- Each ACLI version is only supported for 6 months after release. Update regularly.
- ACLI is for **Atlassian Cloud only**. It does not work with Jira Server or Data Center.
- The tool is published under the `atlassian-labs` GitHub organization, which is Atlassian's space for experimental and community-supported projects. It is not part of the core Atlassian product suite, but it is maintained by Atlassian employees.
