# Shell Cosmetics - Implementation Plan

This plan adds colorful, consistent terminal appearance across macOS and Linux (Ubuntu Desktop, Server, and WSL). The prompt is already handled by Starship; this feature covers everything else: file listing colors, readline behavior, man page colors, shell options, and helpful aliases.

## What's Already Done

Static files have been copied from the previous dotfiles project into each platform's `files/` directory:

| File | macOS | Ubuntu Desktop | Ubuntu Server | Ubuntu WSL |
|------|-------|---------------|---------------|------------|
| `.inputrc` | `src/os/macos/files/` | `src/os/ubuntu-desktop/files/` | `src/os/ubuntu-server/files/` | `src/os/ubuntu-wsl/files/` |
| `bash_colors.sh` | `src/os/macos/files/` | `src/os/ubuntu-desktop/files/` | `src/os/ubuntu-server/files/` | `src/os/ubuntu-wsl/files/` |

**macOS Terminal.app theme profiles** have been copied to `src/os/macos/files/terminal/`:

| File | Description |
|------|-------------|
| `Solarized Dark.terminal` | Solarized Dark color scheme (default) |
| `Solarized Light.terminal` | Solarized Light color scheme |
| `Ubuntu.terminal` | Ubuntu-style color scheme |
| `Monokai Pro (Filter Spectrum).terminal` | Monokai Pro color scheme |

**macOS AppleScript** for importing themes has been copied to `src/os/macos/preferences/`:

| File | Description |
|------|-------------|
| `set_terminal_theme.applescript` | Imports a .terminal theme and sets it as default |

**Key difference between platforms:**
- macOS uses `LSCOLORS` (FreeBSD format) and `ls -G`
- Linux uses `LS_COLORS` (GNU format) and `ls --color=auto`

---

## Step 1: Create the Shell Cosmetics Installer (macOS)

Create `src/os/macos/installers/shell-cosmetics.sh` following the standard installer pattern.

This installer must:

### 1a. Check if already configured

```bash
#!/bin/bash
set -e

APP_NAME="Shell Cosmetics"

# Check if .inputrc is already symlinked to our version
if [ -L "$HOME/.inputrc" ] && [ "$(readlink "$HOME/.inputrc")" = "$HOME/.dotfiles/src/os/macos/files/.inputrc" ]; then
    echo "$APP_NAME is already configured."
    exit 0
fi
```

### 1b. Deploy .inputrc

Symlink the `.inputrc` file to the user's home directory. Back up any existing file first.

```bash
# Back up existing .inputrc if it exists and is not a symlink
if [ -f "$HOME/.inputrc" ] && [ ! -L "$HOME/.inputrc" ]; then
    echo "Backing up existing .inputrc to .inputrc.bak"
    mv "$HOME/.inputrc" "$HOME/.inputrc.bak"
fi

# Create symlink
ln -sf "$HOME/.dotfiles/src/os/macos/files/.inputrc" "$HOME/.inputrc"
```

### 1c. Verify

```bash
if [ -L "$HOME/.inputrc" ]; then
    echo "$APP_NAME configured."
else
    echo "Error: Failed to configure $APP_NAME."
    exit 1
fi
```

---

## Step 2: Update .bash_profile (macOS)

Edit `src/os/macos/files/.bash_profile` to add the following sections. Insert them in logical order between the existing sections.

### 2a. Add Terminal Color Detection

Add this **before** the "Shell Options" section. This upgrades the TERM variable to enable 256-color support when available:

```bash
# ------------------------------------------------------------------------------
# Terminal Color Support
# ------------------------------------------------------------------------------

if [[ $COLORTERM == gnome-* && $TERM == xterm ]] \
    && infocmp gnome-256color &> /dev/null; then
    export TERM="gnome-256color"
elif infocmp xterm-256color &> /dev/null; then
    export TERM="xterm-256color"
fi

# Source platform-specific color configuration (LSCOLORS)
if [[ -f ~/.dotfiles/src/os/macos/files/bash_colors.sh ]]; then
    source ~/.dotfiles/src/os/macos/files/bash_colors.sh
fi
```

### 2b. Add Missing Shell Options

Add these to the existing "Shell Options" section (after the current `shopt` commands):

```bash
shopt -s checkwinsize       # Update LINES/COLUMNS after each command
shopt -s cmdhist            # Save multi-line commands in one history entry
shopt -s dotglob            # Include dotfiles in globbing
shopt -s extglob            # Extended pattern matching
shopt -s no_empty_cmd_completion  # No PATH search on empty line completion
```

Note: `autocd` is intentionally omitted because it can cause confusion and the `set -o vi` option is handled by `.inputrc` instead.

### 2c. Add Missing Exports

Add a new "Environment" section **after** Shell Options:

```bash
# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Default editor
export EDITOR="vim"

# Prefer US English and use UTF-8 encoding
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Colored man pages
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"

# Don't clear the screen after quitting a man page
export MANPAGER="less -X"

# Make Python use UTF-8 encoding for output
export PYTHONIOENCODING="UTF-8"

# History: ignore commands starting with space and duplicates
HISTCONTROL=ignoreboth

# History: don't record these commands
HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"

# Silence macOS bash deprecation warning
export BASH_SILENCE_DEPRECATION_WARNING=1
```

### 2d. Add Missing Aliases

Expand the existing "Aliases" section:

```bash
# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# File operations (verbose + interactive)
alias cp="cp -iv"
alias mv="mv -iv"
alias mkdir="mkdir -pv"

# Listing
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Quick commands
alias c="clear"
alias q="exit"
alias e="vim --"
alias m="man"
alias path='printf "%b\n" "${PATH//:/\\n}"'
```

---

## Step 3: Update .zshrc (macOS)

Edit `src/os/macos/files/.zshrc` with the same additions. Zsh uses the same `LSCOLORS` variable on macOS.

### 3a. Add Terminal Color Detection

Add **before** the "Shell Options" section:

```bash
# ------------------------------------------------------------------------------
# Terminal Color Support
# ------------------------------------------------------------------------------

if [[ $COLORTERM == gnome-* && $TERM == xterm ]] \
    && infocmp gnome-256color &> /dev/null; then
    export TERM="gnome-256color"
elif infocmp xterm-256color &> /dev/null; then
    export TERM="xterm-256color"
fi

# Source platform-specific color configuration (LSCOLORS)
if [[ -f ~/.dotfiles/src/os/macos/files/bash_colors.sh ]]; then
    source ~/.dotfiles/src/os/macos/files/bash_colors.sh
fi
```

### 3b. Add Missing Exports

Same as Step 2c, but remove `BASH_SILENCE_DEPRECATION_WARNING` (bash-specific) and `HISTCONTROL`/`HISTIGNORE` (already handled by zsh's `setopt` in the existing config).

### 3c. Add Missing Aliases

Same aliases as Step 2d.

---

## Step 4: Create Shell Cosmetics Installer (Ubuntu Desktop)

Create `src/os/ubuntu-desktop/installers/shell-cosmetics.sh` following the same pattern as Step 1, but with the Ubuntu path:

```bash
ln -sf "$HOME/.dotfiles/src/os/ubuntu-desktop/files/.inputrc" "$HOME/.inputrc"
```

---

## Step 5: Create Shell Cosmetics Installer (Ubuntu Server)

Create `src/os/ubuntu-server/installers/shell-cosmetics.sh` — same as Step 4 with path adjusted to `src/os/ubuntu-server/files/.inputrc`.

---

## Step 6: Create Shell Cosmetics Installer (Ubuntu WSL)

Create `src/os/ubuntu-wsl/installers/shell-cosmetics.sh` — same as Step 4 with path adjusted to `src/os/ubuntu-wsl/files/.inputrc`.

---

## Step 7: Create .bash_profile for Ubuntu Platforms

Each Ubuntu platform needs a `.bash_profile` (or `.bashrc` — Ubuntu sources `.bashrc` for interactive shells). Create `src/os/ubuntu-desktop/files/.bashrc` (and equivalents for server/wsl) with these sections:

1. **Terminal Color Detection** — same as Step 2a but source the Ubuntu `bash_colors.sh` path
2. **Dotfiles Functions** — source from the platform's functions directory (if/when created)
3. **Shell Options** — same `shopt` settings as Step 2b
4. **Environment** — same exports as Step 2c (without `BASH_SILENCE_DEPRECATION_WARNING`)
5. **Aliases** — same as Step 2d
6. **Starship Prompt** — `eval "$(starship init bash)"`

**Important:** Ubuntu's default `.bashrc` contains useful platform defaults. Merge rather than replace — keep Ubuntu's existing completion sourcing and conditional color support, then add our customizations at the end.

---

## Step 8: Create Terminal Theme Preferences Script (macOS)

Create `src/os/macos/preferences/terminal-theme.sh` to import the `.terminal` theme profiles and set the default.

This script lives in `preferences/` (not `installers/`) because it configures an application preference rather than installing software.

### How It Works

1. The `.terminal` files in `src/os/macos/files/terminal/` are Terminal.app profile definitions (plist format) containing all color settings for the Solarized/Ubuntu/Monokai themes.
2. The `set_terminal_theme.applescript` in `src/os/macos/preferences/` uses AppleScript to open a `.terminal` file (which imports it into Terminal.app), then sets it as the default profile.

### 8a. The Preferences Script

```bash
#!/bin/bash
set -e

APP_NAME="Terminal Theme"
THEME_NAME="Solarized Dark"
DOTFILES_DIR="$HOME/.dotfiles"
THEMES_DIR="$DOTFILES_DIR/src/os/macos/files/terminal"
APPLESCRIPT="$DOTFILES_DIR/src/os/macos/preferences/set_terminal_theme.applescript"

# 1. Check if Terminal.app default theme is already set
#    (We can't easily check this without AppleScript, so we check if the
#    theme file exists as a signal that we've done this before)
PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
if [ -f "$PLIST" ]; then
    CURRENT_DEFAULT=$(/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" "$PLIST" 2>/dev/null || echo "")
    if [ "$CURRENT_DEFAULT" = "$THEME_NAME" ]; then
        echo "$APP_NAME is already configured."
        exit 0
    fi
fi

# 2. Check dependencies
if [ ! -d "$THEMES_DIR" ]; then
    echo "Error: Theme files not found at $THEMES_DIR"
    exit 1
fi

if [ ! -f "$APPLESCRIPT" ]; then
    echo "Error: AppleScript not found at $APPLESCRIPT"
    exit 1
fi

if [ ! -f "$THEMES_DIR/$THEME_NAME.terminal" ]; then
    echo "Error: Theme file '$THEME_NAME.terminal' not found."
    exit 1
fi

# 3. Remove quarantine attributes (files downloaded from GitHub may be quarantined)
echo "Preparing theme files..."
xattr -d com.apple.quarantine "$THEMES_DIR"/*.terminal 2>/dev/null || true
xattr -d com.apple.quarantine "$APPLESCRIPT" 2>/dev/null || true

# 4. Run the AppleScript to import and set the theme
echo "Importing '$THEME_NAME' theme into Terminal.app..."
osascript "$APPLESCRIPT"

# 5. Verify
CURRENT_DEFAULT=$(/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" "$PLIST" 2>/dev/null || echo "")
if [ "$CURRENT_DEFAULT" = "$THEME_NAME" ]; then
    echo "$APP_NAME configured."
else
    echo "Warning: Theme may not have been set as default. Manual verification recommended."
fi
```

### 8b. Understanding the AppleScript

The existing `set_terminal_theme.applescript` does the following:
1. Records IDs of all currently open Terminal windows
2. Opens the `.terminal` file (this imports it into Terminal.app's profile list)
3. Waits 1 second for the import to complete
4. Sets the imported theme as the default profile
5. Applies the theme to all currently open windows
6. Closes any extra windows that were opened during import

**Important:** The AppleScript references the theme file path relative to its own location. The preferences script must ensure the `.terminal` file path is accessible. If needed, the AppleScript can be updated to accept the theme path as an argument.

### 8c. Available Themes

Four themes are provided. To change the default, update `THEME_NAME` in the preferences script:

| Theme | Description |
|-------|-------------|
| `Solarized Dark` | Dark background, muted colors (default) |
| `Solarized Light` | Light background, same Solarized palette |
| `Ubuntu` | Ubuntu terminal colors on dark background |
| `Monokai Pro (Filter Spectrum)` | Monokai-inspired dark theme |

---

## Step 9: Wire Installers into Setup Scripts

### macOS

Add a call to `shell-cosmetics.sh` in `src/os/macos/setup.sh`. Place it in the "Fonts & prompt" group (group 2), after `shell-config.sh`:

```bash
run_installer "shell-cosmetics"  "installers/shell-cosmetics.sh"
```

Add the terminal theme to the preferences section (called by `apply_preferences()`):

```bash
run_preference "terminal-theme"  "preferences/terminal-theme.sh"
```

### Ubuntu Desktop / Server / WSL

Add equivalent calls in each platform's `setup.sh` once those orchestrators are expanded. (No terminal theme step for Ubuntu — handled by `set_terminal_theme.sh` in the Ubuntu-specific preferences, which is a separate feature.)

---

## Step 10: Verify in a Pristine VM

**Do NOT test locally.** Push to GitHub and test in a fresh VM for each platform:

1. **macOS** — Fresh macOS VM, run the remote install command
2. **Ubuntu Desktop** — Fresh Ubuntu Desktop VM
3. **Ubuntu Server** — Fresh Ubuntu Server VM
4. **Ubuntu WSL** — Fresh WSL instance

### Verification Checklist

For each platform, confirm:

- [ ] `ls` output is colorized (directories cyan, executables green, symlinks distinct)
- [ ] Tab completion cycles through options (not just beeps)
- [ ] Up/down arrows search history by prefix (type partial command, press up)
- [ ] `man ls` shows colored headings (green/bold)
- [ ] `echo $TERM` shows `xterm-256color` (or equivalent)
- [ ] `echo $EDITOR` shows `vim`
- [ ] `echo $LANG` shows `en_US`
- [ ] Starship prompt still displays correctly with colors
- [ ] The `.inputrc` symlink points to the dotfiles version: `ls -la ~/.inputrc`
- [ ] (macOS only) Terminal.app default profile is "Solarized Dark"
- [ ] (macOS only) Terminal.app window uses Solarized colors (dark background, muted text)

---

## File Summary

After implementation, the relevant file tree should look like:

```
src/os/
├── macos/
│   ├── files/
│   │   ├── .bash_profile      # Updated with colors, options, exports, aliases
│   │   ├── .zshrc             # Updated with colors, exports, aliases
│   │   ├── .inputrc           # Readline config (symlinked to ~/.inputrc)
│   │   ├── bash_colors.sh     # LSCOLORS for BSD ls (sourced by .bash_profile/.zshrc)
│   │   ├── starship.toml      # (existing)
│   │   └── terminal/          # Terminal.app theme profiles
│   │       ├── Solarized Dark.terminal
│   │       ├── Solarized Light.terminal
│   │       ├── Ubuntu.terminal
│   │       └── Monokai Pro (Filter Spectrum).terminal
│   ├── installers/
│   │   └── shell-cosmetics.sh # Deploys .inputrc symlink
│   └── preferences/
│       ├── terminal-theme.sh          # Imports theme and sets as default
│       └── set_terminal_theme.applescript  # AppleScript for Terminal.app automation
├── ubuntu-desktop/
│   ├── files/
│   │   ├── .inputrc           # Readline config
│   │   └── bash_colors.sh     # LS_COLORS for GNU ls
│   └── installers/
│       └── shell-cosmetics.sh # Deploys .inputrc, updates .bashrc
├── ubuntu-server/
│   ├── files/
│   │   ├── .inputrc           # Readline config
│   │   └── bash_colors.sh     # LS_COLORS for GNU ls
│   └── installers/
│       └── shell-cosmetics.sh # Deploys .inputrc, updates .bashrc
└── ubuntu-wsl/
    ├── files/
    │   ├── .inputrc           # Readline config
    │   └── bash_colors.sh     # LS_COLORS for GNU ls
    └── installers/
        └── shell-cosmetics.sh # Deploys .inputrc, updates .bashrc
```

---

## Notes

- **Starship handles the prompt.** Do NOT add PS1/PS2/PS4 customization — that's Starship's job. The old project's `bash_prompt` file is replaced entirely by Starship.
- **Git status in prompt** is handled by Starship's `[git_status]` module, not a custom function.
- **The `bash_colors.sh` file is sourced, not symlinked.** It defines environment variables and aliases that must exist in the current shell session.
- **The `.inputrc` file is symlinked.** Readline reads it from `~/.inputrc` automatically.
- **All scripts must be idempotent.** Running setup multiple times must produce the same result without errors.
- **Terminal.app themes are macOS-specific.** The `.terminal` files are plist-format profiles that only work with macOS Terminal.app. If iTerm2 is the primary terminal, these themes won't apply there — iTerm2 has its own color scheme format (`.itermcolors`). The theme step only configures Terminal.app.
- **The AppleScript requires Terminal.app to be running.** The preferences script should be run during an interactive setup session, not headlessly.
