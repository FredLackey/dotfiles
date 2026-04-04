# Atlassian CLI (ACLI) - Ubuntu Server Installation

## Tool Overview

**Name:** Atlassian Command Line Interface (ACLI)  
**Vendor:** Atlassian (first-party, official)  
**Purpose:** Command-line tool for managing Jira Cloud (projects, work items, users, boards, sprints, fields) and Atlassian admin tasks without leaving the terminal. Supports bulk operations, scripting, CI/CD integration, and output redirection.  
**Official Documentation:** https://developer.atlassian.com/cloud/acli/guides/introduction/  
**Installation Guide:** https://developer.atlassian.com/cloud/acli/guides/install-linux/

## Ubuntu Server Availability

**Yes** -- ACLI is fully supported on Linux, including headless Ubuntu Server. Atlassian provides both an APT repository (preferred) and a standalone binary download via curl. No GUI is required.

**Important limitation:** ACLI only works with Jira Cloud. It does not support Jira Data Center or Jira Server. Atlassian Government Cloud is also not supported.

## Prerequisites and Dependencies

- Ubuntu Server (any currently supported LTS release)
- `wget` and `gnupg2` (for APT repository setup)
- Network access to `acli.atlassian.com`
- An Atlassian Cloud account with an API token (for authentication after install)

## Installation (APT -- Recommended)

This is the preferred method on Ubuntu Server. It registers Atlassian's APT repository so you get updates through normal `apt upgrade` workflows.

### 1. Install dependencies

```bash
sudo apt-get update
sudo apt-get install -y wget gnupg2
```

### 2. Add the Atlassian ACLI APT repository

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings

wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg

sudo chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/acli.list > /dev/null
```

### 3. Install ACLI

```bash
sudo apt update
sudo apt install -y acli
```

## Installation (curl -- Alternative)

Use this if you do not have root access or prefer not to add a third-party APT repository.

### For x86-64 (most common on servers)

```bash
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
chmod +x ./acli
```

### For ARM64

```bash
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"
chmod +x ./acli
```

### Move into place

**System-wide (requires root):**

```bash
sudo install -o root -g root -m 0755 acli /usr/local/bin/acli
```

**User-only (no root required):**

```bash
mkdir -p ~/.local/bin
mv ./acli ~/.local/bin/acli
```

If using the user-only path, make sure `~/.local/bin` is on your `$PATH`. Add this to `~/.bashrc` if it is not already there:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Verification

```bash
acli --help
```

You should see the ACLI help output listing available commands (`jira`, `admin`, `rovodev`) and global flags. If the command is not found, confirm the binary location is on your `$PATH`.

## Post-Install: Authentication Setup

ACLI requires authentication before you can run any useful commands. On a headless server, use API token authentication (the browser-based OAuth flow requires a GUI).

### 1. Generate an API token

Go to https://id.atlassian.com/manage-profile/security/api-tokens in a browser (on any machine), click "Create API token", give it a label, and copy the token value.

For admin-level commands, you also need an API key from https://admin.atlassian.com (Settings > API Keys).

### 2. Authenticate with your Jira site

```bash
echo "YOUR_API_TOKEN" | acli jira auth login \
  --site "yoursite.atlassian.net" \
  --email "you@example.com" \
  --token
```

Or read the token from a file (safer -- avoids token in shell history):

```bash
acli jira auth login \
  --site "yoursite.atlassian.net" \
  --email "you@example.com" \
  --token < ~/secrets/atlassian-token.txt
```

### 3. Verify the connection

```bash
acli jira auth status
```

This should show your authenticated site and account.

## Quick Usage Examples

```bash
# List projects
acli jira project list

# Create a task
acli jira workitem create --summary "Fix login bug" --project "TEAM" --type "Task"

# Transition a ticket to Done
acli jira workitem transition --key "TEAM-42" --status "Done"
```

## Notes

- Each ACLI release is only supported for 6 months. Update regularly via `sudo apt update && sudo apt upgrade acli` (APT method) or re-download the binary (curl method).
- ACLI is Jira Cloud only. If you are running Jira Data Center or Jira Server on-prem, this tool will not work. Look at the third-party Appfire CLI or `jira-cli` (https://github.com/ankitpokhrel/jira-cli) as alternatives.
- On headless servers, do not use `acli jira auth login --web` as it tries to open a browser.
- Store API tokens securely. Do not commit them to version control. Consider using a secrets manager or restricting file permissions (`chmod 600`) on any token file.

## Sources

- https://developer.atlassian.com/cloud/acli/guides/introduction/
- https://developer.atlassian.com/cloud/acli/guides/install-acli/
- https://developer.atlassian.com/cloud/acli/guides/install-linux/
- https://developer.atlassian.com/cloud/acli/guides/how-to-get-started/
- https://www.atlassian.com/blog/jira/atlassian-command-line-interface
