# gitego Installation Plan

This document provides step-by-step instructions for integrating gitego into the dotfiles repository across all supported operating systems.

**Target OSes:**
- macOS
- ubuntu-24-wks (Ubuntu 24 Workstation)
- ubuntu-24-svr (Ubuntu 24 Server)
- ubuntu-23-svr (Ubuntu 23 Server)
- ubuntu-22-svr (Ubuntu 22 Server)
- ubuntu-20-svr (Ubuntu 20 Server)
- ubuntu-original (Generic Ubuntu)
- raspberry-pi-os (Raspberry Pi OS)

**Reference Documentation:** See `ai-docs/GITEGO_HOWTO.md` for detailed gitego usage instructions.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [File Changes Summary](#file-changes-summary)
4. [Step 1: Create Go Installation Scripts](#step-1-create-go-installation-scripts)
5. [Step 2: Create gitego Installation Script](#step-2-create-gitego-installation-script)
6. [Step 3: Update bash_exports for PATH and GPG_TTY](#step-3-update-bash_exports-for-path-and-gpg_tty)
7. [Step 4: Update main.sh Files](#step-4-update-mainsh-files)
8. [Step 5: Verification](#step-5-verification)
9. [Rollback Procedure](#rollback-procedure)

---

## Overview

gitego is a CLI tool for managing multiple Git identities. It requires:
1. **Go** - To compile and install gitego
2. **PATH configuration** - `$HOME/go/bin` must be in PATH for the `gitego` command
3. **GPG_TTY export** - Required for GPG commit signing to work properly

### What's Already Installed

Some gitego dependencies are already handled by existing dotfiles scripts:

| Component | macOS | Ubuntu/Debian |
|-----------|-------|---------------|
| **GPG** | ✅ `gpg.sh` | ✅ `docker.sh` (gnupg) |
| **Pinentry** | ✅ `gpg.sh` (pinentry-mac) | ❌ Need to add (pinentry-tty) |
| **Go** | ❌ Need to add | ❌ Need to add |

This plan focuses on adding the missing components (Go, pinentry-tty for Ubuntu, and gitego itself).

### Installation Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Install Go     │───▶│ Install gitego  │───▶│ Configure PATH  │
│  (OS-specific)  │    │ (cross-platform)│    │ and GPG_TTY     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## Prerequisites

Before implementing this plan, ensure you have:
- [ ] Access to all OS environments for testing (or VM/containers)
- [ ] Read `ai-docs/GITEGO_HOWTO.md` to understand gitego functionality
- [ ] Familiarity with the dotfiles repository structure (see `CLAUDE.md`)

---

## File Changes Summary

| Action | File Path | Description |
|--------|-----------|-------------|
| **CREATE** | `src/os/installs/macos/go.sh` | Install Go via Homebrew |
| **CREATE** | `src/os/installs/ubuntu-24-wks/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/ubuntu-24-svr/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/ubuntu-23-svr/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/ubuntu-22-svr/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/ubuntu-20-svr/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/ubuntu-original/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/raspberry-pi-os/go.sh` | Install Go + pinentry-tty via APT |
| **CREATE** | `src/os/installs/gitego.sh` | Cross-platform gitego installation |
| **MODIFY** | `src/shell/bash_exports` | Add Go bin PATH and GPG_TTY |
| **MODIFY** | `src/os/installs/macos/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-24-wks/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-24-svr/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-23-svr/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-22-svr/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-20-svr/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/ubuntu-original/main.sh` | Add go.sh and gitego.sh calls |
| **MODIFY** | `src/os/installs/raspberry-pi-os/main.sh` | Add go.sh and gitego.sh calls |

---

## Step 1: Create Go Installation Scripts

Go installation differs by OS (Homebrew vs APT), so we need OS-specific scripts.

### 1.1 macOS: `src/os/installs/macos/go.sh`

Create the file with these contents:

```bash
#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Go\n\n"

brew_install "Go" "go"
```

Make executable:
```bash
chmod +x src/os/installs/macos/go.sh
```

### 1.2 Ubuntu/Debian Variants

Create identical `go.sh` files for each Ubuntu variant and Raspberry Pi OS.

**Template for all Ubuntu/Debian variants:**

```bash
#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Go\n\n"

install_package "Go" "golang-go"

# Pinentry for GPG signing in terminal (complements gnupg installed by docker.sh)
install_package "Pinentry TTY" "pinentry-tty"
```

**Note:** GPG (`gnupg`) is already installed by `docker.sh` on Ubuntu/Debian variants. The `pinentry-tty` package ensures GPG signing works reliably in terminal sessions, similar to how `pinentry-mac` is installed on macOS via `gpg.sh`.

Create this file in each of these directories:
- `src/os/installs/ubuntu-24-wks/go.sh`
- `src/os/installs/ubuntu-24-svr/go.sh`
- `src/os/installs/ubuntu-23-svr/go.sh`
- `src/os/installs/ubuntu-22-svr/go.sh`
- `src/os/installs/ubuntu-20-svr/go.sh`
- `src/os/installs/ubuntu-original/go.sh`
- `src/os/installs/raspberry-pi-os/go.sh`

Make all executable:
```bash
chmod +x src/os/installs/ubuntu-*/go.sh
chmod +x src/os/installs/raspberry-pi-os/go.sh
```

---

## Step 2: Create gitego Installation Script

gitego installation is cross-platform (uses `go install`), so create a single script in the parent directory.

### 2.1 Create `src/os/installs/gitego.sh`

```bash
#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare -r GITEGO_REPO="github.com/bgreenwell/gitego"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gitego() {

    # Ensure Go bin directory is in PATH for this session
    export PATH="$HOME/go/bin:$PATH"

    execute \
        "go install ${GITEGO_REPO}@main" \
        "gitego (install from source)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   gitego\n\n"

    # Check if Go is available
    if ! cmd_exists "go"; then
        print_error "gitego (Go is not installed - skipping)"
        return 1
    fi

    # Install or update gitego
    if ! cmd_exists "gitego"; then
        install_gitego
    else
        print_success "gitego"
    fi

}

main
```

Make executable:
```bash
chmod +x src/os/installs/gitego.sh
```

**Note:** We use `@main` instead of `@latest` as recommended in the GITEGO_HOWTO.md to get the most recent features including GPG signing key support.

---

## Step 3: Update bash_exports for PATH and GPG_TTY

gitego requires:
1. `$HOME/go/bin` in PATH (where Go installs binaries)
2. `GPG_TTY` environment variable (for GPG signing to work in terminal)

### 3.1 Edit `src/shell/bash_exports`

Add the following sections to the file. Add them near the top, after the existing `~/.local/bin` PATH entry (around line 12):

**Add Go bin to PATH (after the existing ~/.local/bin PATH entry):**

```bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add Go bin directory to PATH (used by gitego and other Go tools)

export PATH="$HOME/go/bin:$PATH"
```

**Add GPG_TTY export (add this as a new section, before the vim EDITOR section):**

```bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set GPG_TTY for GPG signing operations (required by gitego and git commit signing)

export GPG_TTY=$(tty)
```

### 3.2 Final bash_exports Order (first ~35 lines)

After your edits, the top of bash_exports should look like:

```bash
#!/bin/bash

# Bash Variables.
# https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add ~/.local/bin to PATH (used by pipx, Claude Code, etc.)

export PATH="$HOME/.local/bin:$PATH"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add Go bin directory to PATH (used by gitego and other Go tools)

export PATH="$HOME/go/bin:$PATH"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set GPG_TTY for GPG signing operations (required by gitego and git commit signing)

export GPG_TTY=$(tty)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Stop the macOS Terminal from showing a warning
# ... (rest of file continues)
```

---

## Step 4: Update main.sh Files

Add `go.sh` and `gitego.sh` to each OS's main.sh file. The order matters: Go must be installed before gitego.

### 4.1 macOS: `src/os/installs/macos/main.sh`

Add these two lines after `./gpg.sh` (around line 17):

```bash
./go.sh
./../gitego.sh
```

**Recommended placement** (showing context):
```bash
./compression_tools.sh
./gpg.sh
./go.sh              # <-- ADD THIS
./../gitego.sh       # <-- ADD THIS
./image_tools.sh
```

### 4.2 Ubuntu Workstation: `src/os/installs/ubuntu-24-wks/main.sh`

Add these two lines after `./misc_tools.sh` (around line 20):

```bash
./go.sh
./../gitego.sh
```

**Recommended placement** (showing context):
```bash
./misc.sh
./misc_tools.sh
./go.sh              # <-- ADD THIS
./../gitego.sh       # <-- ADD THIS
./docker.sh
```

### 4.3 All Ubuntu Server Variants and Raspberry Pi OS

Apply the same changes to these files:
- `src/os/installs/ubuntu-24-svr/main.sh`
- `src/os/installs/ubuntu-23-svr/main.sh`
- `src/os/installs/ubuntu-22-svr/main.sh`
- `src/os/installs/ubuntu-20-svr/main.sh`
- `src/os/installs/ubuntu-original/main.sh`
- `src/os/installs/raspberry-pi-os/main.sh`

Add the lines in the same position as ubuntu-24-wks (after `./misc_tools.sh`, before `./docker.sh`).

---

## Step 5: Verification

After implementing all changes, verify the installation works on each OS.

### 5.1 Test Installation Scripts Individually

```bash
# Test Go installation (run from dotfiles root)
./src/os/installs/macos/go.sh      # on macOS
# or
./src/os/installs/ubuntu-24-wks/go.sh  # on Ubuntu workstation

# Verify Go installed
go version
# Expected: go version go1.2x.x ...

# Test gitego installation
./src/os/installs/gitego.sh

# Verify gitego installed
gitego --version
```

### 5.2 Test Full Setup

Run the full setup script on a test environment:

```bash
cd ~/projects/dotfiles/src/os && ./setup.sh
```

### 5.3 Verification Checklist

For each OS, verify:

- [ ] `go version` outputs Go version (1.18+ recommended)
- [ ] `which gitego` shows `$HOME/go/bin/gitego`
- [ ] `gitego --version` outputs version info
- [ ] `echo $GPG_TTY` outputs current TTY (e.g., `/dev/ttys001`)
- [ ] New shell sessions have gitego in PATH (close and reopen terminal)
- [ ] (Ubuntu/Debian only) `dpkg -l | grep pinentry-tty` shows package installed

### 5.4 Test gitego Functionality

```bash
# List profiles (should be empty initially)
gitego list

# Check status
gitego status
```

---

## Rollback Procedure

If issues occur, revert changes in this order:

### Quick Rollback

```bash
# From dotfiles root
git checkout -- src/shell/bash_exports
git checkout -- src/os/installs/*/main.sh

# Remove created files
rm -f src/os/installs/gitego.sh
rm -f src/os/installs/macos/go.sh
rm -f src/os/installs/ubuntu-*/go.sh
rm -f src/os/installs/raspberry-pi-os/go.sh
```

### Uninstall gitego and Go

If you need to remove gitego and Go from a system:

```bash
# Remove gitego binary
rm -f "$HOME/go/bin/gitego"

# Remove Go (macOS)
brew uninstall go

# Remove Go (Ubuntu/Debian)
sudo apt remove golang-go

# Remove pinentry-tty (Ubuntu/Debian only - optional, doesn't affect other functionality)
sudo apt remove pinentry-tty

# Optional: Remove Go workspace
rm -rf "$HOME/go"
```

---

## Notes for Junior Developers

### Key Concepts

1. **Sourcing utils.sh**: Every install script must source the utilities:
   ```bash
   cd "$(dirname "${BASH_SOURCE[0]}")" && . "../../utils.sh" && . "./utils.sh"
   ```

2. **execute() function**: Wrap commands in `execute` for consistent output:
   ```bash
   execute "command here" "Human readable description"
   ```

3. **Cross-platform vs OS-specific**:
   - Cross-platform scripts go in `src/os/installs/` (e.g., `gitego.sh`)
   - OS-specific scripts go in `src/os/installs/{os}/` (e.g., `go.sh`)

4. **Calling cross-platform scripts**: Use `../` prefix:
   ```bash
   ./../gitego.sh  # calls parent directory script
   ```

### Common Issues

| Issue | Solution |
|-------|----------|
| "command not found: gitego" | Ensure `$HOME/go/bin` is in PATH, restart terminal |
| "command not found: go" | Go not installed, run go.sh first |
| "gpg failed to sign" | Ensure GPG_TTY is exported, run `export GPG_TTY=$(tty)` |
| Permission denied on .sh file | Run `chmod +x filename.sh` |

### Testing Tips

1. Test on a fresh VM or container when possible
2. Test both the individual script and full setup.sh
3. Verify new shell sessions work (close and reopen terminal)
4. Check that existing functionality isn't broken

---

## Change Log

| Date | Author | Description |
|------|--------|-------------|
| 2024-12-18 | Claude | Initial plan created |

---

## Approval

- [ ] Plan reviewed by: _______________
- [ ] Implementation approved by: _______________
- [ ] Testing completed on all target OSes
