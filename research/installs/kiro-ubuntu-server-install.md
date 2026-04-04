# Kiro CLI -- Ubuntu Server Installation

## Tool Overview

| Field | Value |
|---|---|
| **Name** | Kiro CLI |
| **Publisher** | Amazon Web Services (AWS) |
| **Description** | AI-powered agentic development tool for the terminal. Uses Claude frontier models to assist with building, testing, and deploying applications via natural language. |
| **Official Site** | https://kiro.dev |
| **CLI Docs** | https://kiro.dev/docs/cli/ |
| **Installation Docs** | https://kiro.dev/docs/cli/installation/ |
| **Authentication Docs** | https://kiro.dev/docs/cli/authentication/ |
| **Downloads Page** | https://kiro.dev/downloads/ |
| **GitHub** | https://github.com/kirodotdev/Kiro |
| **Current Version** | 0.11.130 (as of April 2026) |
| **License** | Proprietary (included with Kiro subscription tiers) |
| **Pricing** | Free tier available; Pro $20/mo, Pro+ $40/mo, Power $200/mo |

## Ubuntu Server Availability

**Yes -- Kiro CLI is available for headless Ubuntu Server.**

Kiro has two components:

- **Kiro IDE** -- A GUI application (VS Code fork). Not suitable for headless servers.
- **Kiro CLI** -- A terminal-only tool. Works on headless servers over SSH. This is the relevant component.

The CLI supports 64-bit x86_64 and ARM aarch64 on recent distributions of Ubuntu, Fedora, and Amazon Linux 2023.

## Prerequisites

### glibc Version

Kiro CLI requires glibc 2.34 or newer. Ubuntu 22.04+ ships with glibc 2.35, so any modern Ubuntu Server meets this requirement.

Check your version:

```bash
ldd --version
```

If your system has glibc older than 2.34, use the musl build instead (see Manual Installation below).

### Dependencies

- `curl` -- for downloading the installer
- `unzip` -- for the zip installation method
- An AWS Builder ID or AWS IAM Identity Center account for authentication

Install dependencies if missing:

```bash
sudo apt-get update && sudo apt-get install -y curl unzip
```

## Installation

### Method 1: One-Line Installer (Recommended)

```bash
curl -fsSL https://cli.kiro.dev/install | bash
```

The installer will prompt to modify your shell configuration. Pass `--no-confirm` to skip the prompt:

```bash
curl -fsSL https://cli.kiro.dev/install | bash -s -- --no-confirm
```

Restart your shell or source your profile after installation:

```bash
source ~/.bashrc
```

### Method 2: Ubuntu .deb Package

```bash
wget https://desktop-release.q.us-east-1.amazonaws.com/latest/kiro-cli.deb
sudo dpkg -i kiro-cli.deb
sudo apt-get install -f
```

### Method 3: Manual Zip Install

For x86_64 with glibc 2.34+:

```bash
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip' \
  -o kirocli.zip
unzip kirocli.zip
./kirocli/install.sh
```

For ARM aarch64 with glibc 2.34+:

```bash
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-aarch64-linux.zip' \
  -o kirocli.zip
unzip kirocli.zip
./kirocli/install.sh
```

For older systems (musl build, no glibc requirement):

```bash
# x86_64
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux-musl.zip' \
  -o kirocli.zip

# ARM aarch64
curl --proto '=https' --tlsv1.2 -sSf \
  'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-aarch64-linux-musl.zip' \
  -o kirocli.zip

unzip kirocli.zip
./kirocli/install.sh
```

The default install location is `~/.local/bin`.

## Verification

```bash
kiro-cli version
```

Run the built-in diagnostic:

```bash
kiro-cli doctor
```

Expected output: `Everything looks good!`

## Authentication on Headless Servers

Since Ubuntu Server has no browser, you cannot use the standard login flow. There are two approaches depending on your auth provider.

### Option A: Device Code Flow (Builder ID or IAM Identity Center)

This is the simplest approach for headless servers. Builder ID and IAM Identity Center automatically use device code flow when no browser is detected.

```bash
kiro-cli login
```

The CLI will display a URL and a one-time code. Open that URL in a browser on any other machine, enter the code, and complete authentication. No port forwarding needed.

### Option B: SSH Port Forwarding (GitHub or Google Social Login)

Social logins (GitHub, Google) use PKCE OAuth, which requires a localhost callback. This means you need SSH port forwarding.

1. On the server, run:

   ```bash
   kiro-cli login
   ```

2. Select "Use for Free with Google or GitHub."

3. Note the port number displayed (e.g., `49153`).

4. On your local machine, open a second terminal and create the tunnel:

   ```bash
   ssh -L 49153:localhost:49153 -N user@your-server
   ```

   For EC2 with a key file:

   ```bash
   ssh -i ~/.ssh/my-key.pem -L 49153:localhost:49153 -N ubuntu@your-server
   ```

5. Press Enter in the server's CLI session.

6. Complete authentication in your local browser. The callback will tunnel back through SSH.

Keep the SSH tunnel open until authentication completes. Add `-o ServerAliveInterval=60` if the connection drops mid-auth.

### Troubleshooting Authentication

| Issue | Fix |
|---|---|
| Timeout during auth | Verify port forwarding is active and port matches CLI output |
| Port already in use | Run `lsof -i :<PORT>` on the server to find conflicts |
| Local port conflict | Close stale SSH sessions or tunnels |
| Social login unavailable | Use Builder ID or IAM Identity Center instead |

Sign out:

```bash
kiro-cli logout
```

Re-authenticate:

```bash
kiro-cli login
```

## Post-Install Configuration

### SSH Server Config (for Remote Sessions)

If you connect to this server via SSH and want Kiro CLI to work properly in those sessions, add these lines to `/etc/ssh/sshd_config`:

```
AcceptEnv Q_SET_PARENT
AllowStreamLocalForwarding yes
```

Then restart sshd:

```bash
sudo systemctl restart sshd
```

### Proxy Configuration (Corporate Networks)

If the server is behind a proxy:

```bash
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1
```

Add these to `~/.bashrc` to persist across sessions.

### Key Features Available in CLI

- Interactive chat with AI in the terminal
- Custom agents for task-specific workflows
- MCP (Model Context Protocol) integration for external tools
- Smart hooks for automated pre/post command actions
- Agent steering via team configuration files
- Context-aware autocomplete

### Useful Commands

| Command | Purpose |
|---|---|
| `kiro-cli` | Start interactive session |
| `kiro-cli login` | Authenticate |
| `kiro-cli logout` | Sign out |
| `kiro-cli doctor` | Run diagnostics |
| `kiro-cli version` | Show version |
| `kiro-cli issue` | Report a bug |
| `kiro-cli uninstall` | Remove Kiro CLI |

Within an interactive session, use `/help`, `/model`, `/usage`, `/load`, `/save`, `/prompts`, `/quit`, and `!` prefix for shell commands.

## Uninstallation

If installed via .deb:

```bash
sudo apt-get remove kiro-cli
sudo apt-get purge kiro-cli
```

If installed via the one-line installer or zip:

```bash
kiro-cli uninstall
```

## Research Notes

- Researched: April 2026
- Kiro reached General Availability in November 2025 with CLI support
- The CLI shares configuration (steering files, MCP settings) with the Kiro IDE
- Kiro CLI is distributed under a proprietary AWS license, not open source
- There is an open GitHub issue (#5938) requesting native headless/SIGV4 auth for CI/CD pipelines without browser interaction, which may improve over time
