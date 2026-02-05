# Starship Integration - Implementation Plan

## Priority Order

1. Zsh on macOS (primary development environment)
2. Bash on macOS
3. Bash on Ubuntu Linux (Desktop, Server, WSL)
4. PowerShell on Windows

---

## Phase 1: macOS — Zsh + Bash

### Step 1: Create the Nerd Font Installer

**File to create:** `src/os/macos/installers/nerd-fonts.sh`

This script installs MesloLG Nerd Font (primary), FiraCode Nerd Font, and JetBrains Mono Nerd Font via Homebrew.

**What to do:**

1. Create the file at `src/os/macos/installers/nerd-fonts.sh`
2. Add the shebang (`#!/bin/bash`) and `set -e`
3. Set `APP_NAME="Nerd Fonts"`
4. **Check step:** Use `brew list font-meslo-lg-nerd-font` to see if the primary font is already installed. If it is, print "Nerd Fonts are already installed." and `exit 0`.
5. **Dependency step:** Verify Homebrew is installed (`command -v brew`). If not, print an error and `exit 1`.
6. **Install step:** Run:
   - `brew install --quiet font-meslo-lg-nerd-font`
   - `brew install --quiet font-fira-code-nerd-font`
   - `brew install --quiet font-jetbrains-mono-nerd-font`
7. **Verify step:** Run `brew list font-meslo-lg-nerd-font` again. If it succeeds, print success. If it fails, print an error and `exit 1`.

---

### Step 2: Create the Starship Installer

**File to create:** `src/os/macos/installers/starship.sh`

This script installs the Starship binary via Homebrew.

**What to do:**

1. Create the file at `src/os/macos/installers/starship.sh`
2. Add the shebang (`#!/bin/bash`) and `set -e`
3. Set `APP_NAME="Starship"`
4. **Check step:** Use `command -v starship` to see if Starship is already installed. If it is, print "Starship is already installed." and `exit 0`.
5. **Dependency step:** Verify Homebrew is installed (`command -v brew`). If not, print an error and `exit 1`.
6. **Install step:** Run `brew install --quiet starship`
7. **Verify step:** Run `command -v starship` again. If it succeeds, print success. If it fails, print an error and `exit 1`.

---

### Step 3: Create the Starship Configuration File

**File to create:** `src/os/macos/files/starship.toml`

This is the shared Starship configuration that will be copied to `~/.config/starship.toml` during setup. It is used by all shells (Zsh, Bash, PowerShell) so it only needs to be created once.

**What to do:**

1. Create the file at `src/os/macos/files/starship.toml`
2. Start with the Nerd Font Symbols preset as a base (run `starship preset nerd-font-symbols` to see the defaults, or reference the Starship docs)
3. Include these module configurations at minimum:

```toml
# Starship Configuration
# Installed by dotfiles: https://github.com/FredLackey/dotfiles
# Uses Nerd Font Symbols preset as baseline

format = """
$directory\
$git_branch\
$git_status\
$git_commit\
$nodejs\
$package\
$docker_context\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[directory]
truncation_length = 4
truncate_to_repo = true
style = "bold cyan"

[git_branch]
symbol = " "
style = "bold purple"

[git_status]
style = "bold red"

[git_commit]
tag_symbol = "  "

[nodejs]
symbol = " "
style = "bold green"

[package]
symbol = "󰏗 "
style = "bold 208"

[docker_context]
symbol = " "
style = "bold blue"

[cmd_duration]
min_time = 2_000
style = "bold yellow"
```

4. Keep the config simple and readable — avoid overly complex formatting

---

### Step 4: Create the Starship Config Installer

**File to create:** `src/os/macos/installers/starship-config.sh`

This script copies the `starship.toml` file into place at `~/.config/starship.toml`.

**What to do:**

1. Create the file at `src/os/macos/installers/starship-config.sh`
2. Add the shebang (`#!/bin/bash`) and `set -e`
3. Set `APP_NAME="Starship Config"`
4. Define the source path: `SOURCE="$HOME/.dotfiles/src/os/macos/files/starship.toml"`
5. Define the target path: `TARGET="$HOME/.config/starship.toml"`
6. **Check step:** Compare the source and target files using `diff -q`. If they are identical, print "Starship config is already up to date." and `exit 0`.
7. **Dependency step:** Verify Starship is installed (`command -v starship`). If not, print an error and `exit 1`. Verify the source file exists. If not, print an error and `exit 1`.
8. **Install step:** Run `mkdir -p "$HOME/.config"` then `cp "$SOURCE" "$TARGET"`
9. **Verify step:** Run `diff -q "$SOURCE" "$TARGET"`. If it succeeds (files match), print success. If it fails, print an error and `exit 1`.

---

### Step 5: Update the macOS `.zshrc` to Initialize Starship

**File to modify:** `src/os/macos/files/.zshrc`

**What to do:**

1. Open `src/os/macos/files/.zshrc`
2. Find the existing prompt section (look for the lines starting with `# Prompt` down to the `PROMPT=` line). It currently looks like this:

```zsh
# Prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '
```

3. Replace that entire block with:

```zsh
# Prompt (Starship)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
```

4. The `if` guard ensures the shell still works even if Starship is not yet installed — the shell just won't have a fancy prompt.

---

### Step 6: Update the macOS `.bash_profile` to Initialize Starship

**File to modify:** `src/os/macos/files/.bash_profile`

**What to do:**

1. Open `src/os/macos/files/.bash_profile`
2. Find the existing prompt section. Look for the `parse_git_branch()` function and the `PS1=` line that uses it. It currently looks something like this:

```bash
# Prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -n 's/* \(.*\)/ (\1)/p'
}
PS1='\[\e[36m\]\w\[\e[33m\]$(parse_git_branch)\[\e[0m\] \$ '
```

3. Replace that entire block with:

```bash
# Prompt (Starship)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
```

4. Same reasoning as above — the guard ensures the shell works without Starship.

---

### Step 7: Add Installers to the macOS Orchestrator

**File to modify:** `src/os/macos/setup.sh`

**What to do:**

1. Open `src/os/macos/setup.sh`
2. Find the section where CLI tools are installed (after `git.sh`, `bash-completion.sh`, etc.)
3. Add these four `run_installer` calls in this specific order (fonts first, then Starship binary, then config):

```bash
run_installer "nerd-fonts.sh"
run_installer "starship.sh"
run_installer "starship-config.sh"
```

4. Place them after the core CLI tools section (after `git.sh`) but before the Languages & Runtimes section. The fonts and Starship binary have no dependency on NVM/Node, so they can go early.

---

### Step 8: Test Phase 1

**Do NOT test locally.** Push to GitHub and test in a pristine macOS virtual machine.

**How to verify:**

1. Run the full setup from scratch on a clean macOS VM
2. Open a new terminal window (to pick up the new `.zshrc`)
3. Confirm Starship prompt appears with the correct symbols
4. Navigate to a Git repository and confirm the branch name shows with the  icon
5. Navigate to a Node.js project and confirm the Node version shows with the  icon
6. Run a command that takes more than 2 seconds (e.g., `sleep 3`) and confirm the duration shows
7. Switch the terminal font to MesloLGM Nerd Font Mono and confirm all glyphs render correctly
8. Open a new Bash shell (`bash`) and confirm Starship also works there

---

## Phase 2: Ubuntu Linux — Bash

### Step 9: Create the Ubuntu Nerd Font Installer

**File to create:** `src/os/ubuntu-desktop/installers/nerd-fonts.sh`

Ubuntu does not use Homebrew for fonts. Fonts are installed manually to `~/.local/share/fonts/`.

**What to do:**

1. Create the directory `src/os/ubuntu-desktop/installers/` if it does not exist
2. Create the file at `src/os/ubuntu-desktop/installers/nerd-fonts.sh`
3. Add the shebang (`#!/bin/bash`) and `set -e`
4. Set `APP_NAME="Nerd Fonts"`
5. Define `FONT_DIR="$HOME/.local/share/fonts"`
6. **Check step:** Look for existing MesloLG Nerd Font files in the font directory. If `ls "$FONT_DIR"/MesloLGM*.ttf` succeeds, print "Nerd Fonts are already installed." and `exit 0`.
7. **Dependency step:** Verify `curl` and `unzip` are available. If not, print an error and `exit 1`.
8. **Install step:**
   - `mkdir -p "$FONT_DIR"`
   - Download Meslo: `curl -fsSL -o /tmp/Meslo.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"`
   - Download FiraCode: `curl -fsSL -o /tmp/FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"`
   - Download JetBrainsMono: `curl -fsSL -o /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"`
   - Unzip all to `$FONT_DIR`: `unzip -o /tmp/Meslo.zip -d "$FONT_DIR"` (same for FiraCode, JetBrainsMono)
   - Rebuild font cache: `fc-cache -fv`
   - Clean up: `rm -f /tmp/Meslo.zip /tmp/FiraCode.zip /tmp/JetBrainsMono.zip`
9. **Verify step:** Check that `fc-list | grep -i "MesloLGM Nerd"` returns results. If it does, print success. If not, print an error and `exit 1`.

---

### Step 10: Create the Ubuntu Starship Installer

**File to create:** `src/os/ubuntu-desktop/installers/starship.sh`

On Ubuntu, install Starship using the official install script (not Homebrew).

**What to do:**

1. Create the file at `src/os/ubuntu-desktop/installers/starship.sh`
2. Add the shebang (`#!/bin/bash`) and `set -e`
3. Set `APP_NAME="Starship"`
4. **Check step:** Use `command -v starship` to see if Starship is already installed. If yes, `exit 0`.
5. **Dependency step:** Verify `curl` is available. If not, print an error and `exit 1`.
6. **Install step:** Run `curl -sS https://starship.rs/install.sh | sh -s -- --yes`
7. **Verify step:** Run `command -v starship` again. If it succeeds, print success. If not, print an error and `exit 1`.

---

### Step 11: Create the Ubuntu Starship Config Installer

**File to create:** `src/os/ubuntu-desktop/installers/starship-config.sh`

Same logic as the macOS version (Step 4), but the source path uses the Ubuntu files directory.

**What to do:**

1. Create the file at `src/os/ubuntu-desktop/installers/starship-config.sh`
2. Same logic as Step 4, but use source path: `SOURCE="$HOME/.dotfiles/src/os/ubuntu-desktop/files/starship.toml"`
3. If you want to avoid duplicating the `starship.toml` file, you can instead point to a shared location such as `$HOME/.dotfiles/src/shared/files/starship.toml` (and create that directory). **Decision:** For now, copy the same `starship.toml` from the macOS files into `src/os/ubuntu-desktop/files/starship.toml`. We can refactor to a shared location later.

---

### Step 12: Create the Ubuntu `.bashrc` with Starship Init

**File to create:** `src/os/ubuntu-desktop/files/.bashrc`

**What to do:**

1. Create the directory `src/os/ubuntu-desktop/files/` if it does not exist
2. Create a `.bashrc` file appropriate for Ubuntu
3. Include the Starship init at the end of the prompt section:

```bash
# Prompt (Starship)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
```

4. Do NOT include a fallback `PS1=` line — if Starship is not installed, the Ubuntu default prompt will remain.

---

### Step 13: Create the Ubuntu Desktop Orchestrator

**File to modify:** `src/os/ubuntu-desktop/setup.sh`

The current file is a stub. Build it out following the same pattern as the macOS orchestrator, but only including the Starship-related installers for now.

**What to do:**

1. Open `src/os/ubuntu-desktop/setup.sh`
2. Add a `run_installer()` function (same pattern as macOS)
3. Call the installers in order:
   - `run_installer "nerd-fonts.sh"`
   - `run_installer "starship.sh"`
   - `run_installer "starship-config.sh"`
4. After the installers, add a step to copy the `.bashrc` file into `$HOME` (or append the Starship init if a `.bashrc` already exists — use the same pattern as the macOS setup for RC file deployment)

---

### Step 14: Replicate for Ubuntu Server and Ubuntu WSL

**Files to create/modify:**
- `src/os/ubuntu-server/installers/` — same installer scripts as ubuntu-desktop
- `src/os/ubuntu-wsl/installers/` — same installer scripts as ubuntu-desktop

**What to do:**

1. Copy the three installer scripts (`nerd-fonts.sh`, `starship.sh`, `starship-config.sh`) into each directory
2. Copy the `files/starship.toml` and `files/.bashrc` into each platform's `files/` directory
3. Update each platform's `setup.sh` to call the installers (same as Step 13)

**WSL-specific note:** The Nerd Font installer for WSL should print a warning that fonts also need to be installed on the Windows host for Windows Terminal to render them. The WSL installer should still install the fonts inside WSL (for any Linux-native terminal use) but include an informational message:

```bash
echo "NOTE: For Windows Terminal, also install Nerd Fonts on the Windows host."
```

---

### Step 15: Test Phase 2

Push to GitHub and test on pristine Ubuntu VMs (Desktop, Server, and WSL).

**How to verify:**

1. Run the full setup from scratch
2. Open a new terminal session
3. Confirm Starship prompt appears
4. Test the same scenarios as Phase 1 (Git repo, Node project, long command)
5. For WSL, test in Windows Terminal with the font configured on the Windows side

---

## Phase 3: Windows — PowerShell

### Step 16: Create the Windows Starship Installer

**File to create:** `src/os/windows/installers/starship.ps1`

On Windows, install Starship via `winget` (preferred) or the official installer.

**What to do:**

1. Create the directory `src/os/windows/installers/` if it does not exist
2. Create the file at `src/os/windows/installers/starship.ps1`
3. **Check step:** Run `Get-Command starship -ErrorAction SilentlyContinue`. If it exists, print "Starship is already installed." and `exit 0`.
4. **Install step:** Run `winget install --id Starship.Starship --accept-source-agreements --accept-package-agreements`
5. **Verify step:** Refresh the path and check for Starship again.

---

### Step 17: Create the Windows Nerd Font Installer

**File to create:** `src/os/windows/installers/nerd-fonts.ps1`

**What to do:**

1. Create the file at `src/os/windows/installers/nerd-fonts.ps1`
2. **Check step:** Look for MesloLG Nerd Font in the Windows fonts directory (`C:\Windows\Fonts\` or the user fonts directory)
3. **Install step:** Download the font zip from the Nerd Fonts GitHub releases, extract, and install using the Shell.Application COM object or `Add-Font` if available. Alternatively, use `winget` or `choco` if a package exists:
   - `winget` does not have Nerd Fonts, so use direct download
   - Download `https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip`
   - Extract to a temp directory
   - Copy `.ttf` files to `$env:LOCALAPPDATA\Microsoft\Windows\Fonts\`
   - Register them via registry or `Add-Type`
4. **Verify step:** Confirm the font files exist in the fonts directory

---

### Step 18: Create the Windows Starship Config Installer

**File to create:** `src/os/windows/installers/starship-config.ps1`

**What to do:**

1. Create the file at `src/os/windows/installers/starship-config.ps1`
2. Copy `starship.toml` to `$env:USERPROFILE\.config\starship.toml`
3. Same check/install/verify pattern as the bash version, but in PowerShell syntax

---

### Step 19: Create the PowerShell Profile with Starship Init

**File to create:** `src/os/windows/files/Microsoft.PowerShell_profile.ps1`

**What to do:**

1. Create the file with the Starship initialization:

```powershell
# Prompt (Starship)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
```

2. The installer should copy this file to `$PROFILE` path (typically `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)

---

### Step 20: Update the Windows Orchestrator

**File to modify:** `src/os/windows/setup.ps1`

**What to do:**

1. Open `src/os/windows/setup.ps1`
2. Add function to run installers (PowerShell equivalent of `run_installer`)
3. Call the installers in order:
   - `nerd-fonts.ps1`
   - `starship.ps1`
   - `starship-config.ps1`
4. Copy the PowerShell profile into place

---

### Step 21: Test Phase 3

Push to GitHub and test on a pristine Windows VM.

**How to verify:**

1. Run the full setup from a fresh PowerShell session
2. Close and reopen PowerShell (or Windows Terminal)
3. Confirm Starship prompt appears
4. Set the terminal font to MesloLGM Nerd Font Mono in Windows Terminal settings
5. Test the same scenarios as previous phases

---

## File Checklist

### New Files to Create

| # | File | Phase |
|---|------|-------|
| 1 | `src/os/macos/installers/nerd-fonts.sh` | 1 |
| 2 | `src/os/macos/installers/starship.sh` | 1 |
| 3 | `src/os/macos/files/starship.toml` | 1 |
| 4 | `src/os/macos/installers/starship-config.sh` | 1 |
| 5 | `src/os/ubuntu-desktop/installers/nerd-fonts.sh` | 2 |
| 6 | `src/os/ubuntu-desktop/installers/starship.sh` | 2 |
| 7 | `src/os/ubuntu-desktop/installers/starship-config.sh` | 2 |
| 8 | `src/os/ubuntu-desktop/files/starship.toml` | 2 |
| 9 | `src/os/ubuntu-desktop/files/.bashrc` | 2 |
| 10 | `src/os/ubuntu-server/installers/nerd-fonts.sh` | 2 |
| 11 | `src/os/ubuntu-server/installers/starship.sh` | 2 |
| 12 | `src/os/ubuntu-server/installers/starship-config.sh` | 2 |
| 13 | `src/os/ubuntu-server/files/starship.toml` | 2 |
| 14 | `src/os/ubuntu-server/files/.bashrc` | 2 |
| 15 | `src/os/ubuntu-wsl/installers/nerd-fonts.sh` | 2 |
| 16 | `src/os/ubuntu-wsl/installers/starship.sh` | 2 |
| 17 | `src/os/ubuntu-wsl/installers/starship-config.sh` | 2 |
| 18 | `src/os/ubuntu-wsl/files/starship.toml` | 2 |
| 19 | `src/os/ubuntu-wsl/files/.bashrc` | 2 |
| 20 | `src/os/windows/installers/nerd-fonts.ps1` | 3 |
| 21 | `src/os/windows/installers/starship.ps1` | 3 |
| 22 | `src/os/windows/installers/starship-config.ps1` | 3 |
| 23 | `src/os/windows/files/starship.toml` | 3 |
| 24 | `src/os/windows/files/Microsoft.PowerShell_profile.ps1` | 3 |

### Existing Files to Modify

| # | File | Change | Phase |
|---|------|--------|-------|
| 1 | `src/os/macos/files/.zshrc` | Replace prompt section with Starship init | 1 |
| 2 | `src/os/macos/files/.bash_profile` | Replace prompt section with Starship init | 1 |
| 3 | `src/os/macos/setup.sh` | Add `run_installer` calls for nerd-fonts, starship, starship-config | 1 |
| 4 | `src/os/ubuntu-desktop/setup.sh` | Build out orchestrator with installers | 2 |
| 5 | `src/os/ubuntu-server/setup.sh` | Build out orchestrator with installers | 2 |
| 6 | `src/os/ubuntu-wsl/setup.sh` | Build out orchestrator with installers | 2 |
| 7 | `src/os/windows/setup.ps1` | Build out orchestrator with installers | 3 |
