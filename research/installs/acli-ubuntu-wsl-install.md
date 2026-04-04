# Atlassian CLI (ACLI) - Ubuntu WSL Installation

## Tool Overview

| Field | Value |
|---|---|
| **Tool Name** | Atlassian Command Line Interface (ACLI) |
| **Publisher** | Atlassian (atlassian-labs) |
| **Current Version** | 1.3.17-stable (as of April 2026) |
| **Official Docs** | https://developer.atlassian.com/cloud/acli/guides/install-acli/ |
| **Linux Install Guide** | https://developer.atlassian.com/cloud/acli/guides/install-linux/ |
| **GitHub (Homebrew tap)** | https://github.com/atlassian-labs/homebrew-acli |
| **Ubuntu WSL Available** | Yes |

## Description

ACLI is Atlassian's official command-line tool for interacting with Atlassian Cloud products from the terminal. It supports Jira Cloud, Confluence Cloud, and Atlassian Admin operations. It is aimed at admins and technical users who prefer CLI workflows over the web UI.

Supported products:

- **Jira Cloud** - work items, projects, boards, filters, dashboards, fields, sprints
- **Confluence Cloud** - page and space management
- **Atlassian Admin** - user management, authentication
- **Rovo Dev** - Atlassian's AI coding agent (Beta)

Not supported: Atlassian Government Cloud, Jira Server/Data Center, or Confluence Server/Data Center.

## Prerequisites / Dependencies

- `wget` and `gnupg2` (for the apt installation method)
- A working internet connection (OAuth authentication opens a browser)
- An Atlassian Cloud account with appropriate permissions

## Installation on Ubuntu WSL (apt method - recommended)

This is the cleanest approach for Ubuntu under WSL. It uses Atlassian's official apt repository, which handles updates through the normal `apt upgrade` workflow.

### Step 1: Install dependencies

```bash
sudo apt-get update
sudo apt-get install -y wget gnupg2
```

### Step 2: Add the Atlassian apt repository

```bash
sudo mkdir -p -m 755 /etc/apt/keyrings

wget -nv -O- https://acli.atlassian.com/gpg/public-key.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/acli-archive-keyring.gpg

sudo chmod go+r /etc/apt/keyrings/acli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/acli-archive-keyring.gpg] https://acli.atlassian.com/linux/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/acli.list > /dev/null
```

### Step 3: Install ACLI

```bash
sudo apt update
sudo apt install -y acli
```

### Step 4: Verify installation

```bash
acli --version
acli --help
```

You should see the version number and a list of available commands (auth, jira, confluence, admin, rovodev, config, etc.).

## Alternative: Direct binary download (no root required)

If you cannot or prefer not to use apt, download the binary directly.

### For x86-64 (most WSL setups)

```bash
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
chmod +x ./acli
mkdir -p ~/.local/bin
mv ./acli ~/.local/bin/acli
```

### For ARM64

```bash
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"
chmod +x ./acli
mkdir -p ~/.local/bin
mv ./acli ~/.local/bin/acli
```

Then ensure `~/.local/bin` is on your PATH. Add to `~/.bashrc` or `~/.zshrc` if it is not already:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Verify with:

```bash
acli --version
```

Note: The direct binary method does not auto-update. You will need to re-download manually. Atlassian only supports each CLI version for 6 months after release, so keep it current.

## Post-Install: Authentication

ACLI uses OAuth for authentication. After installation, log in:

```bash
acli auth login
```

This opens a browser window for Atlassian OAuth. You authenticate through the browser and the CLI stores the token locally. On WSL, this should open the default Windows browser automatically if `wslview` or `xdg-open` is configured (see WSL-specific notes below).

Other auth commands:

```bash
acli auth status    # Check which accounts are active
acli auth switch    # Switch between multiple Atlassian accounts
acli auth logout    # Log out of all accounts
```

## WSL-Specific Notes

### Browser for OAuth

ACLI's `auth login` command needs to open a browser. Under WSL, this works if your WSL distro can launch Windows applications. Most modern WSL 2 setups handle this automatically. If the browser does not open:

1. Install `wslu` which provides `wslview` (a WSL-aware `xdg-open` replacement):
   ```bash
   sudo apt install -y wslu
   ```
2. Verify it works: `wslview https://example.com` should open the URL in your Windows browser.
3. If ACLI still cannot find a browser, you may need to set the `BROWSER` environment variable:
   ```bash
   export BROWSER=wslview
   ```

### Architecture detection

The apt method uses `dpkg --print-architecture` to detect your CPU architecture automatically. This works correctly in WSL 2. If using the curl method, most Windows machines running WSL will need the `amd64` binary (x86-64). ARM64 is only needed if you are running WSL on a Windows ARM device (e.g., Surface Pro X or Snapdragon-based laptops).

### Credential storage

ACLI stores OAuth tokens locally in its config directory. These tokens persist across WSL sessions as long as the WSL filesystem is intact. There is nothing Windows-side to configure for credential storage.

### No systemd dependency

ACLI is a standalone binary with no systemd or background service requirements, so it works fine on WSL distributions regardless of whether systemd is enabled.

## Updating

If installed via apt:

```bash
sudo apt update
sudo apt install --only-upgrade acli
```

If installed via direct binary, re-download the latest binary using the same curl commands above.

## Sources

- [Install Atlassian CLI](https://developer.atlassian.com/cloud/acli/guides/install-acli/)
- [Install binary with curl on Linux](https://developer.atlassian.com/cloud/acli/guides/install-linux/)
- [Atlassian CLI Introduction](https://developer.atlassian.com/cloud/acli/guides/introduction/)
- [Introducing the Atlassian CLI (blog post)](https://www.atlassian.com/blog/jira/atlassian-command-line-interface)
- [GitHub: atlassian-labs/homebrew-acli](https://github.com/atlassian-labs/homebrew-acli)
