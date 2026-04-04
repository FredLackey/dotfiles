# Kiro - Ubuntu WSL Installation

## Tool Overview

**Kiro** is an AI-powered development platform from Amazon/AWS that combines spec-driven development with agentic AI coding. It converts natural language prompts into structured requirements (using EARS notation), then generates and modifies code based on those specs. Kiro is available as both an IDE (built on Code OSS, compatible with VS Code extensions) and a standalone CLI for terminal-based workflows.

- **Website:** <https://kiro.dev>
- **Documentation:** <https://kiro.dev/docs>
- **CLI page:** <https://kiro.dev/cli/>
- **Available for Ubuntu WSL:** Yes. The CLI installs natively on Linux (including WSL). The IDE is a desktop application that requires a graphical environment, so it runs on the Windows side, not inside WSL.

## What You Get

| Component | Type | WSL Support |
|-----------|------|-------------|
| Kiro IDE | Desktop app (Code OSS-based) | No. Install the Windows version on the host. |
| Kiro CLI | Terminal tool | Yes. Installs and runs natively in WSL. |

The CLI provides interactive AI chat, custom agents, MCP integration, agent hooks, steering files, and conversation persistence, all from the terminal. It shares the same Kiro account and pricing tier as the IDE.

## Prerequisites

- **curl** or **wget** (one is required; curl is preferred)
- **unzip** (required on Linux for package extraction)
- **sha256sum** (usually pre-installed; used for checksum verification)
- **glibc 2.34+** (Ubuntu 22.04+ satisfies this; Ubuntu 24.04+ is officially listed)
- **jq** (optional; the installer falls back to manual JSON parsing if missing)

On a fresh Ubuntu WSL instance, ensure unzip is installed:

```bash
sudo apt-get update && sudo apt-get install -y curl unzip
```

## CLI Installation

The official installer script handles platform detection, downloads the correct binary, verifies its checksum, and places it in `~/.local/bin`.

### 1. Run the installer

```bash
curl -fsSL https://cli.kiro.dev/install | bash
```

### 2. Ensure ~/.local/bin is in your PATH

The installer will warn you if `~/.local/bin` is not in your PATH. If it is not, add it:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Verify the installation

```bash
kiro --version
```

You should see the installed version number.

### 4. Authenticate

On first use, Kiro will prompt you to authenticate. You can sign in with a social login or an AWS account.

```bash
kiro
```

## IDE Installation (Windows Host)

The Kiro IDE is a desktop application. Under WSL, install it on the Windows side:

1. Download the Windows installer from <https://kiro.dev>
2. Run the installer on Windows
3. Launch Kiro IDE from the Start menu or desktop shortcut
4. On first launch, authenticate and optionally import your VS Code settings, extensions, and theme

The IDE can open folders inside your WSL filesystem using the standard `\\wsl$\` path, similar to how VS Code handles WSL remotes. Look for remote/WSL integration options in the IDE settings.

## Key CLI Commands

During an interactive chat session, these slash commands are available:

| Command | Description |
|---------|-------------|
| `/model` | Select the AI model for the session |
| `/usage` | Show context window usage |
| `/load` / `/save` | Import/export conversation state |
| `/prompts` | List available prompts |
| `/editor` | Compose a prompt in your configured editor |
| `/quit` | Exit the chat |
| `!<command>` | Run a shell command within the session |
| `ctrl-j` | Multi-line input |
| `ctrl-k` | Fuzzy search |

## Supported Languages

Python, Java, JavaScript, TypeScript, C#, Go, Rust, PHP, Ruby, Kotlin, C, C++, shell scripting, SQL, Scala, JSON, YAML, and HCL.

## WSL-Specific Notes

- **The CLI works natively in WSL.** The install script detects Linux x86_64 or ARM64 and downloads the appropriate binary. It does not special-case WSL, but no special handling is needed since WSL presents as standard Linux.
- **The IDE does not run inside WSL.** It is a graphical desktop application. Install it on Windows and use its remote/WSL workspace support to edit files inside the WSL filesystem.
- **glibc version matters.** The installer requires glibc 2.34+. Ubuntu 22.04 (Jammy) ships glibc 2.35, so it qualifies. If you are on an older WSL distro, you will need to upgrade.
- **No musl support confirmed.** The install script checks for glibc vs musl. Alpine-based WSL distros (which use musl) may work but are not in the officially listed platforms.
- **Authentication may open a browser.** The auth flow may attempt to open a browser window. In WSL, this should open your default Windows browser if `wslview` or `xdg-open` is configured. If it does not, copy the URL from the terminal and paste it into a browser manually.
- **Amazon Q CLI migration.** The install script detects existing Amazon Q CLI installations and can update in place. If you previously installed Amazon Q Developer CLI, the Kiro installer may offer to upgrade it.

## Pricing

Kiro CLI is included in the standard Kiro pricing tiers. There is no separate cost for the CLI versus the IDE. Check <https://kiro.dev> for current pricing details.

## Notes

- Kiro is a proprietary tool, not open source. It is distinct from the older open-source Amazon Q Developer CLI.
- The CLI stores conversations per-directory, so project context is maintained automatically between sessions.
- Steering files let you customize AI behavior with project-specific rules and preferences, similar to CLAUDE.md or .cursorrules files.
- MCP (Model Context Protocol) integration allows connecting external tools, databases, and documentation sources.
