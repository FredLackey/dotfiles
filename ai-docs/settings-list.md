# System Settings & Preferences Inventory

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`, `src/os/macos/functions/`
**Discovered:** 2026-01-24

This document catalogs all system preferences, shell settings, and environment configurations applied by the dotfiles project on macOS. Each entry includes the setting, its value, purpose, and source file.

---

## Table of Contents

1. [Shell Options (Bash)](#shell-options-bash)
2. [Shell Options (Zsh)](#shell-options-zsh)
3. [History Configuration](#history-configuration)
4. [Environment Variables](#environment-variables)
5. [PATH Configuration](#path-configuration)
6. [Prompt Configuration](#prompt-configuration)
7. [Completion Configuration](#completion-configuration)
8. [Aliases](#aliases)
9. [Git Configuration](#git-configuration)
10. [NVM Configuration](#nvm-configuration)
11. [Custom Functions Sourcing](#custom-functions-sourcing)
12. [macOS System Preferences (defaults write)](#macos-system-preferences-defaults-write)

---

## Shell Options (Bash)

**Source:** `src/os/macos/files/.bash_profile`

| Option | Command | Purpose |
|--------|---------|---------|
| histappend | `shopt -s histappend` | Append to history file instead of overwriting on shell exit |
| cdspell | `shopt -s cdspell` | Auto-correct minor spelling errors in `cd` directory names |
| nocaseglob | `shopt -s nocaseglob` | Case-insensitive filename globbing |

---

## Shell Options (Zsh)

**Source:** `src/os/macos/files/.zshrc`

### History

| Option | Command | Purpose |
|--------|---------|---------|
| HIST_IGNORE_DUPS | `setopt HIST_IGNORE_DUPS` | Don't record duplicate consecutive history entries |
| HIST_IGNORE_SPACE | `setopt HIST_IGNORE_SPACE` | Don't record commands that start with a space |
| SHARE_HISTORY | `setopt SHARE_HISTORY` | Share history between all active zsh sessions |

### Navigation

| Option | Command | Purpose |
|--------|---------|---------|
| AUTO_CD | `setopt AUTO_CD` | Change to a directory by typing its name without `cd` |
| AUTO_PUSHD | `setopt AUTO_PUSHD` | Automatically push directories onto the directory stack |
| PUSHD_IGNORE_DUPS | `setopt PUSHD_IGNORE_DUPS` | Don't push duplicate directories onto the stack |

### Completion

| Option | Command | Purpose |
|--------|---------|---------|
| COMPLETE_IN_WORD | `setopt COMPLETE_IN_WORD` | Allow completion from the cursor position within a word |
| ALWAYS_TO_END | `setopt ALWAYS_TO_END` | Move cursor to end of word after completion |

### Prompt

| Option | Command | Purpose |
|--------|---------|---------|
| PROMPT_SUBST | `setopt PROMPT_SUBST` | Enable parameter expansion and command substitution in prompts |

---

## History Configuration

### Bash

**Source:** `src/os/macos/files/.bash_profile`

| Variable | Value | Purpose |
|----------|-------|---------|
| HISTSIZE | `10000` | Number of history entries kept in memory |
| HISTFILESIZE | `20000` | Maximum lines saved in the history file on disk |
| HISTCONTROL | `ignoreboth` | Ignore both duplicate commands and commands starting with a space |

### Zsh

**Source:** `src/os/macos/files/.zshrc`

| Variable | Value | Purpose |
|----------|-------|---------|
| HISTFILE | `~/.zsh_history` | Location of the history file |
| HISTSIZE | `10000` | Number of history entries kept in memory |
| SAVEHIST | `10000` | Number of entries saved to the history file |

---

## Environment Variables

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`

| Variable | Value | Purpose | Shell |
|----------|-------|---------|-------|
| NVM_DIR | `$HOME/.nvm` | Node Version Manager installation directory | Both |

---

## PATH Configuration

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`

Both shells configure Homebrew paths with architecture detection:

| Condition | Command | Purpose |
|-----------|---------|---------|
| Apple Silicon (`/opt/homebrew/bin/brew` exists) | `eval "$(/opt/homebrew/bin/brew shellenv)"` | Add Homebrew paths for ARM Macs |
| Intel (`/usr/local/bin/brew` exists) | `eval "$(/usr/local/bin/brew shellenv)"` | Add Homebrew paths for Intel Macs |

The `brew shellenv` command sets: `HOMEBREW_PREFIX`, `HOMEBREW_CELLAR`, `HOMEBREW_REPOSITORY`, and prepends Homebrew directories to `PATH`, `MANPATH`, and `INFOPATH`.

---

## Prompt Configuration

### Bash

**Source:** `src/os/macos/files/.bash_profile`

```bash
export PS1='\[\033[36m\]\w\[\033[33m\]$(__git_branch)\[\033[00m\] \$ '
```

| Element | Code | Display |
|---------|------|---------|
| Working directory | `\w` | Cyan colored current path |
| Git branch | `$(__git_branch)` | Yellow colored branch name (via helper function) |
| Prompt character | `\$` | `$` for normal user, `#` for root |

**Helper function** `__git_branch()`: Extracts the current git branch name from `git branch` output.

### Zsh

**Source:** `src/os/macos/files/.zshrc`

```bash
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '
```

| Element | Code | Display |
|---------|------|---------|
| Working directory | `%~` | Cyan colored current path (with `~` abbreviation) |
| Git branch | `${vcs_info_msg_0_}` | Yellow colored branch name via vcs_info |
| Prompt character | `%#` | `%` for normal user, `#` for root |

**VCS Info setup:**
```bash
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
```

---

## Completion Configuration

### Bash

**Source:** `src/os/macos/files/.bash_profile`

| Condition | Source File | Purpose |
|-----------|-------------|---------|
| Homebrew bash-completion@2 exists | `${BREW_PREFIX}/etc/profile.d/bash_completion.sh` | Modern completion for bash 4+ |
| Legacy bash-completion exists | `${BREW_PREFIX}/etc/bash_completion` | Fallback completion for bash 3.x |

### Zsh

**Source:** `src/os/macos/files/.zshrc`

| Command | Purpose |
|---------|---------|
| `autoload -Uz compinit && compinit` | Initialize the zsh completion system |

---

## Aliases

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`

Both shells define the same aliases:

| Alias | Expansion | Purpose |
|-------|-----------|---------|
| `ll` | `ls -la` | Long listing showing all files including hidden |
| `la` | `ls -A` | List all files excluding `.` and `..` |
| `l` | `ls -CF` | Classify files by type with column output |

**Note:** Additional aliases are defined in the custom functions loaded via `main.sh` (see [function-list.md](function-list.md) for the full aliases reference).

---

## Git Configuration

**Sources:** `src/os/macos/functions/bash/set-git-public.sh`, `src/os/macos/functions/zsh/set-git-public.sh`

When the `set-git-public` function is invoked, it sets:

| Setting | Command | Value |
|---------|---------|-------|
| User email | `git config user.email` | `fred.lackey@gmail.com` |
| User name | `git config user.name` | `Fred Lackey` |

These are applied as local (per-repository) git configurations.

---

## NVM Configuration

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`

Both shells load NVM with a two-tier fallback:

| Priority | Condition | Source | Purpose |
|----------|-----------|--------|---------|
| 1 | Homebrew NVM exists | `$(brew --prefix)/opt/nvm/nvm.sh` | Load NVM installed via Homebrew |
| 2 | Standard NVM exists | `$NVM_DIR/nvm.sh` | Load NVM installed manually |

### Bash-specific NVM extras

| Priority | Condition | Source | Purpose |
|----------|-----------|--------|---------|
| 1 | Homebrew NVM completion exists | `$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm` | NVM tab completion via Homebrew |
| 2 | Standard NVM completion exists | `$NVM_DIR/bash_completion` | NVM tab completion via manual install |

---

## Custom Functions Sourcing

**Sources:** `src/os/macos/files/.bash_profile`, `src/os/macos/files/.zshrc`

| Shell | Source File | Purpose |
|-------|-------------|---------|
| Bash | `~/.dotfiles/src/os/macos/functions/bash/main.sh` | Load all custom bash functions and aliases |
| Zsh | `~/.dotfiles/src/os/macos/functions/zsh/main.sh` | Load all custom zsh functions and aliases |

These `main.sh` files aggregate all custom functions, aliases, and additional settings defined in the dotfiles repository.

---

## macOS System Preferences (defaults write)

**Note:** These are currently found only in `_research/` files (untrusted/experimental) and are not yet part of the active installer scripts.

### Xcode Build Performance

**Source:** `_research/installs/xcode.md`

```bash
defaults write com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration -bool YES
```

| Domain | Key | Value | Purpose |
|--------|-----|-------|---------|
| `com.apple.dt.XCBuild` | `EnableSwiftBuildSystemIntegration` | `YES` | Enable Swift Build System Integration for improved Xcode build performance |

### Safari Technology Preview Remote Automation

**Source:** `_research/installs/safari-tech-preview.md`

```bash
defaults write com.apple.Safari.TechnologyPreview AllowRemoteAutomation -bool true
```

| Domain | Key | Value | Purpose |
|--------|-----|-------|---------|
| `com.apple.Safari.TechnologyPreview` | `AllowRemoteAutomation` | `true` | Enable WebDriver/remote automation testing in Safari Technology Preview |

---

## Summary

The dotfiles project configures the following categories of settings on macOS:

| Category | Bash Settings | Zsh Settings | Notes |
|----------|--------------|--------------|-------|
| Shell options | 3 shopt flags | 9 setopt flags | Navigation, globbing, history behavior |
| History | 3 variables | 3 variables | 10k entries, deduplication, session sharing |
| Environment | 1 export | 1 export | NVM_DIR only |
| PATH | 2 conditional evals | 2 conditional evals | Homebrew (Apple Silicon + Intel) |
| Prompt | PS1 with git branch | PROMPT with vcs_info | Cyan directory, yellow branch |
| Completion | 2 conditional sources | compinit | Homebrew bash-completion or legacy |
| Aliases | 3 aliases | 3 aliases | ls variants (ll, la, l) |
| Git | 2 config values | 2 config values | Via set-git-public function |
| NVM | 2-tier load + completion | 2-tier load | Homebrew or manual install |
| macOS defaults | 2 commands | N/A | Research only, not in active scripts |
