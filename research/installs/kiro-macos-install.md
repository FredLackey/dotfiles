# Kiro - macOS Installation

## Tool Summary

| Field | Value |
|---|---|
| **Tool** | Kiro (IDE + CLI) |
| **Description** | AI-powered agentic IDE and CLI for spec-driven development, from prototype to production |
| **Official Site** | https://kiro.dev/ |
| **Documentation** | https://kiro.dev/docs/ (IDE), https://kiro.dev/docs/cli/ (CLI) |
| **GitHub Repo** | https://github.com/kirodotdev/Kiro |
| **License** | Proprietary (free tier available) |
| **macOS Available** | Yes (Homebrew cask for both IDE and CLI) |
| **CLI Available** | Yes, standalone CLI separate from the IDE |
| **Pricing** | Free tier, Pro $20/mo, Pro+ $40/mo, Power $200/mo |

## What It Is

Kiro is an AWS-backed development platform with two distinct products:

1. **Kiro IDE** - A full agentic IDE built on Code OSS (VS Code fork). It emphasizes spec-driven development where prompts are turned into detailed specs, then into working code, docs, and tests. Installed as a desktop application.

2. **Kiro CLI** - A standalone command-line tool for AI-powered terminal workflows. It supports agent mode, MCP (Model Context Protocol), steering, custom agents, and enterprise automation. This is the successor to the Amazon Q Developer CLI (formerly CodeWhisperer CLI).

Both products are separate installations and work independently. The CLI is not bundled inside the IDE. You can install one or both depending on your workflow.

## History

- Kiro IDE launched in preview in July 2025.
- Kiro reached General Availability on November 17, 2025.
- The Amazon Q Developer CLI was rebranded to Kiro CLI on November 24, 2025 (auto-updated for existing users).
- The Homebrew cask `amazon-q` was renamed to `kiro-cli`.

## Prerequisites

- **macOS 12 or newer** (for the IDE)
- **macOS 11 or newer** (for the CLI)
- **Homebrew** installed (recommended installation method)
- A login account: GitHub, Google, AWS Builder ID, or AWS IAM Identity Center. You do not need an AWS account.

## Installation - Kiro IDE (Homebrew)

The IDE installs as a desktop application at `/Applications/Kiro.app`.

```bash
# 1. Install Kiro IDE
brew install --cask kiro

# 2. Verify the application exists
ls /Applications/Kiro.app
```

Open Kiro from your Applications folder or Spotlight and sign in with your preferred account.

## Installation - Kiro CLI (Homebrew - Recommended)

The CLI installs as a standalone command-line tool.

```bash
# 1. Install Kiro CLI
brew install --cask kiro-cli

# 2. Verify the installation
kiro-cli --version
```

## Installation - Kiro CLI (curl - Alternative)

If you prefer not to use Homebrew:

```bash
# 1. Install via the official install script
curl -fsSL https://cli.kiro.dev/install | bash

# 2. Restart your terminal (or source your shell profile)

# 3. Verify the installation
kiro-cli --version
```

## Verification

### IDE

```bash
# Check the application bundle exists
ls /Applications/Kiro.app

# Or check via Homebrew
brew list --cask kiro
```

### CLI

```bash
# Check version
kiro-cli --version

# Check that the binary is in your PATH
which kiro-cli

# View changelog (optional)
kiro-cli version --changelog
```

## Post-Install Configuration

### Authentication

On first launch (IDE or CLI), you need to sign in. Supported methods:

- **GitHub** - OAuth sign-in
- **Google** - OAuth sign-in
- **AWS Builder ID** - Free, no AWS account required
- **AWS IAM Identity Center** - For enterprise/organizational access

For the CLI, run:

```bash
kiro-cli login
```

### Upgrading from Amazon Q Developer CLI

If you previously had the Amazon Q Developer CLI installed:

- The Homebrew cask `amazon-q` has been renamed to `kiro-cli`.
- If auto-update was enabled, it may have already been upgraded.
- Your existing configuration and settings should carry over.
- See the official migration guide: https://kiro.dev/docs/cli/migrating-from-q/

### Shell Integration (CLI)

Kiro CLI provides shell completions and inline suggestions. Follow the prompts after installation or consult the CLI docs for shell-specific setup.

### Custom Agents (CLI)

Kiro CLI supports custom agents with steering rules and MCP tool integration. Configuration reference: https://kiro.dev/docs/cli/custom-agents/configuration-reference/

## Existing Installer in This Repo

This dotfiles repo already has a Kiro IDE installer at `src/os/macos/installers/kiro.sh` that installs via `brew install --cask kiro`. It installs the IDE only (the desktop application), not the CLI.

If a separate CLI installer is needed, it would use `brew install --cask kiro-cli` and verify with `command -v kiro-cli`.

## Notes

- The IDE and CLI are separate Homebrew casks: `kiro` (IDE) and `kiro-cli` (CLI). Installing one does not install the other.
- Kiro CLI works on both Apple Silicon (M1/M2/M3/M4) and Intel Macs.
- Kiro is available in AWS GovCloud (US) regions as of February 2026.
- Kiro supports a wide range of languages: Python, Java, JavaScript, TypeScript, C#, Go, Rust, PHP, Ruby, Kotlin, C, C++, shell scripting, SQL, Scala, JSON, YAML, and HCL.

## Sources

- [Kiro Official Site](https://kiro.dev/)
- [Kiro CLI Docs - Installation](https://kiro.dev/docs/cli/installation/)
- [Kiro IDE Docs - Installation](https://kiro.dev/docs/getting-started/installation/)
- [Kiro CLI - Homebrew Formulae](https://formulae.brew.sh/cask/kiro-cli)
- [Kiro IDE - Homebrew Formulae](https://formulae.brew.sh/cask/kiro)
- [Kiro CLI - Upgrading from Amazon Q](https://kiro.dev/docs/cli/migrating-from-q/)
- [AWS Launches Kiro into GA - SiliconANGLE](https://siliconangle.com/2025/11/17/aws-launches-kiro-general-availability-team-features-cli-support/)
- [Kiro GitHub Repository](https://github.com/kirodotdev/Kiro)
