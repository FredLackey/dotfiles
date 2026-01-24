# Starship: The Cross-Shell Prompt

A comprehensive guide to understanding and using Starship, the modern alternative to Oh My Zsh + Powerlevel10k.

## Table of Contents

1. [What is Starship?](#what-is-starship)
2. [How It Compares to Oh My Zsh + Powerlevel10k](#how-it-compares-to-oh-my-zsh--powerlevel10k)
3. [Key Features](#key-features)
4. [Benefits and Trade-offs](#benefits-and-trade-offs)
5. [Installation Guide](#installation-guide)
6. [Shell Configuration](#shell-configuration)
7. [Configuration Basics](#configuration-basics)
8. [Popular Modules](#popular-modules)
9. [Presets](#presets)
10. [Sources](#sources)

---

## What is Starship?

**Starship is a minimal, blazing-fast, and infinitely customizable prompt for any shell.** Written in Rust, it provides a single binary that works across Bash, Zsh, Fish, PowerShell, and more.

Think of it like this:
- **Your shell** (Bash, Zsh, Fish, etc.) = the engine
- **Starship** = a universal dashboard that works with any engine

Unlike Oh My Zsh (which is a Zsh-only framework), Starship is:
- A **standalone binary** (not a shell framework)
- **Shell-agnostic** (works with any shell)
- Configured via a **single TOML file**

### What a Starship Prompt Shows

A typical Starship prompt displays:

```
~/projects/my-app on  main via  v20.10.0 took 2s
❯
```

| Element | Meaning |
|---------|---------|
| `~/projects/my-app` | Current directory (truncated) |
|  `main` | Git branch |
|  `v20.10.0` | Node.js version (detected from package.json) |
| `took 2s` | How long the last command took |
| `❯` | Prompt character |

---

## How It Compares to Oh My Zsh + Powerlevel10k

| Aspect | Oh My Zsh + P10k | Starship |
|--------|------------------|----------|
| **Type** | Zsh framework + theme | Standalone binary |
| **Shell Support** | Zsh only | Bash, Zsh, Fish, PowerShell, Elvish, Ion, Tcsh, Xonsh, Nushell, Cmd |
| **Written In** | Zsh script | Rust |
| **Configuration** | `.zshrc` + `.p10k.zsh` | Single `starship.toml` |
| **Plugins** | 300+ plugins for git, docker, etc. | No plugins (shell aliases separate) |
| **Prompt Features** | Extensive prompt customization | Extensive prompt customization |
| **Setup** | Install framework + theme + fonts | Install binary + fonts |
| **Maintenance** | P10k is now on "life support" | Actively maintained |

### Why People Are Switching

In 2025, the Powerlevel10k developer announced the project is on "life support," prompting many users to migrate to Starship. Key reasons include:

1. **Active development** - Starship receives frequent updates
2. **Simpler architecture** - One binary, one config file
3. **Cross-shell consistency** - Same prompt everywhere
4. **Readable configuration** - TOML is easier than P10k's Zsh config

### When to Stick with P10k

- You're exclusively a Zsh user and prioritize raw speed
- You need P10k's "Instant Prompt" feature (Starship lacks this)
- You work in very large Git repositories (P10k is faster for git status)

---

## Key Features

### 1. Cross-Shell Compatibility

Use the same prompt configuration across all your shells:

```
┌──────────────────────────────────────────────────────┐
│                     Starship                          │
│              (single Rust binary)                     │
│                        │                              │
│     ┌──────────┬───────┴────────┬──────────┐         │
│     ▼          ▼                ▼          ▼         │
│   Bash       Zsh             Fish     PowerShell     │
│                                                       │
│  Same starship.toml configuration everywhere          │
└──────────────────────────────────────────────────────┘
```

### 2. Intelligent Context Display

Starship shows information only when relevant:
- Git status appears only in Git repositories
- Node.js version appears only when `package.json` exists
- Python version appears only in Python projects
- Docker context appears only when not using "default"

### 3. Nearly 100 Modules

Available modules include:

| Category | Modules |
|----------|---------|
| **Version Control** | git_branch, git_status, git_commit, git_state, git_metrics |
| **Languages** | nodejs, python, rust, golang, java, ruby, php, dotnet, elixir |
| **Cloud/DevOps** | aws, azure, gcloud, kubernetes, docker_context, terraform |
| **System** | battery, time, memory_usage, cmd_duration, jobs |
| **Shell** | directory, character, username, hostname, shell |

### 4. Transient Prompt

In supported shells (PowerShell, Cmd, Fish), previous prompts can be replaced with a simpler version, keeping your terminal clean:

```
# Before (every line shows full prompt)
~/projects/app on main via v20 ❯ git status
~/projects/app on main via v20 ❯ npm test
~/projects/app on main via v20 ❯

# After (transient prompt enabled)
❯ git status
❯ npm test
~/projects/app on main via v20 ❯
```

---

## Benefits and Trade-offs

### Benefits

| Benefit | Description |
|---------|-------------|
| **Universal** | One configuration works across all shells and operating systems |
| **Fast** | Rust-powered core renders prompts in milliseconds |
| **Simple Setup** | Single binary + single config file |
| **Active Development** | Frequent updates and bug fixes |
| **Easy Configuration** | Human-readable TOML format |
| **Zero Dependencies** | No framework or shell plugins required |
| **Intelligent** | Shows context only when relevant |

### Trade-offs

| Trade-off | Description |
|-----------|-------------|
| **No Instant Prompt** | Unlike P10k, prompt may lag slightly on shell startup |
| **No Plugin System** | Shell plugins (like git aliases) must be configured separately |
| **Git Performance** | Slower than P10k in very large repositories |
| **No Setup Wizard** | Configuration is manual (though presets help) |
| **Fewer Shell Enhancements** | Only customizes the prompt, not shell behavior |

### Important Distinction

**Starship only customizes your prompt.** It does NOT provide:
- Git aliases (`gst`, `gco`, etc.) - use shell aliases or Oh My Zsh plugins
- Tab completion enhancements - configure in your shell
- Directory shortcuts - configure in your shell
- Spelling correction - configure in your shell (Zsh has this built-in)

If you want these features, you can still use Oh My Zsh (without P10k) + Starship together.

---

## Installation Guide

### Prerequisites

**A Nerd Font is required.** Without it, you'll see □ squares instead of icons.

Recommended font: **FiraCode Nerd Font** or **MesloLGS NF**

Download from [Nerd Fonts](https://www.nerdfonts.com/font-downloads) or install via Homebrew:

```bash
brew install --cask font-fira-code-nerd-font
```

### Step 1: Install Starship

#### macOS

```bash
# Using Homebrew (recommended)
brew install starship

# Or using the install script
curl -sS https://starship.rs/install.sh | sh
```

#### Linux

```bash
# Universal install script
curl -sS https://starship.rs/install.sh | sh

# Or use your package manager:
# Arch: pacman -S starship
# Debian/Ubuntu: See releases page for .deb
# Fedora: dnf install starship
```

#### Windows

```powershell
# Using winget (recommended)
winget install --id Starship.Starship

# Or using Scoop
scoop install starship

# Or using Chocolatey
choco install starship
```

### Step 2: Configure Your Terminal Font

Set your terminal to use a Nerd Font:

- **iTerm2**: Preferences → Profiles → Text → Font → FiraCode Nerd Font
- **Terminal.app**: Preferences → Profiles → Font → FiraCode Nerd Font
- **VS Code**: Settings → Terminal › Integrated: Font Family → `FiraCode Nerd Font`
- **Windows Terminal**: Settings → Profiles → Defaults → Appearance → Font face

---

## Shell Configuration

Add the Starship initialization to your shell's config file:

### Bash (`~/.bashrc`)

```bash
eval "$(starship init bash)"
```

### Zsh (`~/.zshrc`)

```bash
eval "$(starship init zsh)"
```

### Fish (`~/.config/fish/config.fish`)

```fish
starship init fish | source
```

### PowerShell (`$PROFILE`)

```powershell
Invoke-Expression (&starship init powershell)
```

### Other Shells

| Shell | Config File | Init Command |
|-------|-------------|--------------|
| Elvish | `~/.elvish/rc.elv` | `eval (starship init elvish)` |
| Ion | `~/.config/ion/initrc` | `eval $(starship init ion)` |
| Nushell | `$nu.config-path` | `starship init nu \| save -f ~/.config/starship.nu` |
| Tcsh | `~/.tcshrc` | `eval `starship init tcsh`` |
| Xonsh | `~/.xonshrc` | `execx($(starship init xonsh))` |

---

## Configuration Basics

Starship uses a single TOML file: `~/.config/starship.toml`

### Create the Config File

```bash
mkdir -p ~/.config && touch ~/.config/starship.toml
```

### Basic Configuration Structure

```toml
# ~/.config/starship.toml

# Prompt format (order and style of modules)
format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$cmd_duration\
$line_break\
$character"""

# Wait 10ms for starship to check files under current directory
scan_timeout = 10

# Disable blank line at start of prompt
add_newline = false

# Module configurations
[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = "🌱 "

[nodejs]
format = "via [ $version](bold green) "

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

### Common Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `format` | The overall prompt format | Shows all enabled modules |
| `add_newline` | Blank line before prompt | `true` |
| `scan_timeout` | Timeout for file checks (ms) | `30` |
| `command_timeout` | Timeout for commands (ms) | `500` |

---

## Popular Modules

### Directory

```toml
[directory]
truncation_length = 3           # Show 3 parent folders
truncate_to_repo = true         # Truncate at git root
fish_style_pwd_dir_length = 1   # Shorten paths like Fish
format = "[$path]($style) "
style = "bold cyan"
```

### Git Branch & Status

```toml
[git_branch]
symbol = " "
format = "on [$symbol$branch]($style) "
truncation_length = 20
style = "bold purple"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "⚔️ "
ahead = "⬆️ ${count}"
behind = "⬇️ ${count}"
diverged = "⬆️ ${ahead_count}⬇️ ${behind_count}"
modified = "📝"
staged = "✅"
untracked = "❓"
```

### Programming Languages

```toml
[nodejs]
format = "via [ $version](bold green) "
detect_files = ["package.json", ".node-version"]

[python]
format = 'via [🐍 $version]($style) '
detect_extensions = ["py"]

[rust]
format = "via [🦀 $version](red bold) "

[golang]
format = "via [🐹 $version](bold cyan) "
```

### Command Duration

```toml
[cmd_duration]
min_time = 2_000                # Show if command took >2s
format = "took [$duration]($style) "
style = "bold yellow"
```

### Kubernetes

```toml
[kubernetes]
disabled = false                # Disabled by default
format = 'on [⛵ $context \($namespace\)](dimmed green) '
```

### Time

```toml
[time]
disabled = false                # Disabled by default
format = '[\[ $time \]]($style) '
time_format = "%T"              # 24-hour format
```

---

## Presets

Starship includes built-in presets for quick setup:

### Available Presets

| Preset | Description |
|--------|-------------|
| **Nerd Font Symbols** | Uses Nerd Font icons for all modules |
| **Plain Text** | No special symbols (for terminals without Nerd Fonts) |
| **Bracketed Segments** | Wraps modules in brackets `[git:main]` |
| **No Nerd Font** | Minimal symbols without Nerd Fonts |
| **Pastel Powerline** | Colorful powerline-style prompt |
| **Tokyo Night** | Tokyo Night color scheme |
| **Gruvbox Rainbow** | Gruvbox colors with powerline segments |

### Apply a Preset

```bash
# List available presets
starship preset --list

# Apply a preset (overwrites starship.toml)
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Or merge with existing config
starship preset bracketed-segments >> ~/.config/starship.toml
```

### Example: Minimal Preset

```toml
# Minimal two-line prompt
format = """
$directory$git_branch$git_status
$character"""

[directory]
style = "blue"

[character]
success_symbol = "[❯](purple)"
error_symbol = "[❯](red)"
```

---

## Using Starship with Oh My Zsh

You can use Starship for the prompt while keeping Oh My Zsh for plugins:

```bash
# ~/.zshrc

# Load Oh My Zsh (for plugins like git aliases)
export ZSH="$HOME/.oh-my-zsh"
plugins=(git docker npm)
source $ZSH/oh-my-zsh.sh

# Use Starship for the prompt (instead of P10k)
eval "$(starship init zsh)"
```

This gives you:
- Oh My Zsh plugins (git aliases, completions, etc.)
- Starship's cross-shell prompt configuration

---

## Sources

- [Starship Official Website](https://starship.rs/)
- [Starship GitHub Repository](https://github.com/starship/starship)
- [Starship Presets](https://starship.rs/presets/)
- [Starship Configuration Guide](https://starship.rs/config/)
- [Powerlevel10k is on Life Support. Hello Starship!](https://hashir.blog/2025/06/powerlevel10k-is-on-life-support-hello-starship/)
- [Moving from powerlevel10k to Starship](https://bulimov.me/post/2025/05/11/powerlevel10k-to-starship/)
- [Starship on Zsh - Medium](https://medium.com/@alfor93/starship-on-zsh-e65d0d8fd595)
- [Customizing Your Shell with Starship - Medium](https://rondevs.medium.com/customizing-your-shell-with-starship-a-modern-fast-and-customizable-prompt-2b458a57f32d)
- [Starship: Open-Source Customizable Prompt - It's FOSS](https://itsfoss.com/starship/)
- [Benefits of using the Starship prompt - JR IT Services](https://www.jr-it-services.de/benefits-of-using-the-starship-prompt/)
- [Nerd Fonts](https://www.nerdfonts.com/)
