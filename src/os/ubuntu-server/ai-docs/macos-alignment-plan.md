# Ubuntu-Server to macOS Alignment Plan

This document provides step-by-step instructions to align the ubuntu-server installer scripts with the patterns used in the working macOS implementation.

## Overview

The macOS implementation has been tested and works correctly. The ubuntu-server implementation has several pattern deviations that need to be corrected for consistency and reliability.

| Priority | Task | File | Issue |
|----------|------|------|-------|
| 1 | Fix dependency failure handling | `installers/yarn.sh` | Uses `exit 0` instead of `exit 1` |
| 2 | Remove auto-update behavior | `installers/nvm.sh` | Violates idempotency principle |
| 3 | Add idempotency check | `installers/shell-config.sh` | Missing upfront check |
| 4 | Use LTS version pattern | `installers/node.sh` | Hardcoded version instead of `--lts` |
| 5 | Add package manager validation | All installers | Missing `dpkg` verification |

---

## Task 1: Fix Dependency Failure Handling in yarn.sh

**File:** `src/os/ubuntu-server/installers/yarn.sh`

**Problem:** When NVM is not found, the script exits with `exit 0` (success), silently skipping the installation. The macOS pattern exits with `exit 1` (failure) to fail fast on missing dependencies.

**Why this matters:** Silent failures hide problems. If a required dependency is missing, the setup should stop and alert the user rather than continuing with an incomplete installation.

### Current Code (Lines 13-17)

```bash
# 2. Check dependencies
if [ ! -d "$NVM_DIR" ]; then
    echo "Warning: NVM not found. Skipping $APP_NAME installation."
    exit 0
fi
```

### Corrected Code

```bash
# 2. Check dependencies
if [ ! -d "$NVM_DIR" ]; then
    echo "Error: NVM is required to install $APP_NAME."
    exit 1
fi
```

### Changes Required

1. Change "Warning" to "Error" in the message
2. Change the message text from "Skipping" to "is required to install"
3. Change `exit 0` to `exit 1`

---

## Task 2: Remove Auto-Update Behavior from nvm.sh

**File:** `src/os/ubuntu-server/installers/nvm.sh`

**Problem:** When NVM is already installed, the script automatically updates it to the latest version. This violates the idempotency principle: scripts should check if an action is needed, perform it only if necessary, and verify success. Auto-updating introduces unexpected side effects.

**Why this matters:** The macOS NVM installer simply exits when NVM exists. Running the setup script should not change already-installed tools unless explicitly requested.

### Current Code (Lines 8-19)

```bash
# 1. Check if already installed
if [ -d "$NVM_DIR" ]; then
    echo "$APP_NAME is already installed."

    # Update to latest version
    echo "Updating $APP_NAME..."
    cd "$NVM_DIR"
    git fetch --quiet origin
    git checkout --quiet "$(git describe --abbrev=0 --tags)"

    exit 0
fi
```

### Corrected Code

```bash
# 1. Check if already installed
if [ -d "$NVM_DIR" ]; then
    echo "$APP_NAME is already installed."
    exit 0
fi
```

### Changes Required

1. Remove lines 12-17 (the entire update block)
2. Keep only the check, echo, and exit

---

## Task 3: Add Idempotency Check to shell-config.sh

**File:** `src/os/ubuntu-server/installers/shell-config.sh`

**Problem:** The script always recreates symlinks, even if they already point to the correct files. The macOS pattern checks if files are already up to date before making changes.

**Why this matters:** True idempotency means "if nothing needs to change, change nothing." Unnecessary file operations (even symlink recreation) can cause issues with file watchers, backups, and audit logs.

### Current Behavior

The `backup_and_link` function removes existing symlinks and recreates them every time:

```bash
# Remove existing symlink
if [ -L "$target" ]; then
    rm "$target"
fi

# Create symlink
ln -s "$source" "$target"
```

### Corrected Approach

Add a check at the beginning of `backup_and_link` to verify if the symlink already points to the correct location:

### Step 1: Modify the backup_and_link function

Replace the current `backup_and_link` function (lines 12-37) with:

```bash
backup_and_link() {
    local source="$1"
    local target="$2"
    local filename=$(basename "$target")

    # Skip if source doesn't exist
    if [ ! -f "$source" ]; then
        echo "Warning: Source file not found: $source"
        return 0
    fi

    # Check if symlink already points to correct location
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo "$filename is already linked correctly."
            return 0
        fi
        # Symlink exists but points elsewhere, remove it
        rm "$target"
    fi

    # Backup existing file if it exists and is not a symlink
    if [ -f "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target to ${target}.backup"
        mv "$target" "${target}.backup"
    fi

    # Create symlink
    echo "Linking $filename"
    ln -s "$source" "$target"
}
```

### Step 2: Add an upfront idempotency check

Add this block after line 8 (after `DOTFILES_DIR` definition), before the `echo "Installing $APP_NAME..."` line:

```bash
# 1. Check if already up to date
check_symlink() {
    local source="$1"
    local target="$2"
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        [ "$current_target" = "$source" ]
    else
        return 1
    fi
}

BASHRC_CURRENT=false
BASH_PROFILE_CURRENT=false

if check_symlink "$FILES_DIR/.bashrc" "$HOME/.bashrc"; then
    BASHRC_CURRENT=true
fi

if check_symlink "$FILES_DIR/.bash_profile" "$HOME/.bash_profile"; then
    BASH_PROFILE_CURRENT=true
fi

if [ "$BASHRC_CURRENT" = true ] && [ "$BASH_PROFILE_CURRENT" = true ]; then
    echo "$APP_NAME is already up to date."
    exit 0
fi
```

---

## Task 4: Use LTS Version Pattern in node.sh

**File:** `src/os/ubuntu-server/installers/node.sh`

**Problem:** The script uses a hardcoded version (`NODE_VERSION="22"`) instead of the `--lts` flag used by macOS. This creates maintenance burden and version drift between platforms.

**Why this matters:** Using `--lts` ensures both platforms install the current LTS version without requiring manual updates to the scripts.

### Current Code (Lines 5, 21, 28-29)

```bash
NODE_VERSION="22"
...
echo "Installing $APP_NAME v$NODE_VERSION..."
...
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
```

### Corrected Code

**Line 4-5:** Change APP_NAME and remove NODE_VERSION

```bash
APP_NAME="Node.js (LTS via NVM)"
NVM_DIR="$HOME/.nvm"
```

**Line 21:** Update the echo message

```bash
echo "Installing $APP_NAME..."
```

**Lines 28-30:** Use --lts flag and lts/* alias

```bash
nvm install --lts
nvm alias default 'lts/*'
nvm use default
```

### Complete Corrected File

```bash
#!/bin/bash
set -e

APP_NAME="Node.js (LTS via NVM)"
NVM_DIR="$HOME/.nvm"

# 1. Check if already installed
if command -v node >/dev/null 2>&1; then
    echo "$APP_NAME is already installed ($(node --version))."
    exit 0
fi

# 2. Check dependencies
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "Error: NVM is required to install $APP_NAME."
    exit 1
fi

# 3. Install
echo "Installing $APP_NAME..."

# Load NVM
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# Install Node LTS
nvm install --lts
nvm alias default 'lts/*'
nvm use default

# 4. Verify
if command -v node >/dev/null 2>&1; then
    echo "$APP_NAME $(node --version) installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
```

---

## Task 5: Add Package Manager Validation to Installers

**Problem:** Ubuntu-server installers only use `command -v` to check if tools are installed. The macOS pattern additionally verifies via the package manager (`brew list`). This provides more robust validation.

**Why this matters:** A command might exist from a previous manual installation or different package manager. Validating via `dpkg` ensures we know the apt-managed version is installed.

### Pattern to Apply

For each installer that uses `apt` to install packages, add a `dpkg` check alongside `command -v`.

### Example: git.sh

**Current pattern:**
```bash
if command -v git >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi
```

**Improved pattern:**
```bash
if command -v git >/dev/null 2>&1 && dpkg -l git 2>/dev/null | grep -q "^ii"; then
    echo "$APP_NAME is already installed."
    exit 0
fi
```

### Files to Update

Apply this pattern to all installers that use `apt-get install`:

1. `installers/git.sh`
2. `installers/curl.sh`
3. `installers/docker.sh` (already has this pattern)
4. `installers/yarn.sh`
5. Any other apt-based installers

### The dpkg Check Explained

- `dpkg -l git 2>/dev/null` - Lists package info for "git", suppressing errors
- `grep -q "^ii"` - Checks if the line starts with "ii" (installed status)
- Combined with `&&` ensures both command exists AND package is installed via apt

---

## Verification Checklist

After making all changes, verify each fix:

- [ ] **yarn.sh**: Run with NVM not installed, confirm it exits with error (exit code 1)
- [ ] **nvm.sh**: Run twice, confirm second run just exits without updating
- [ ] **shell-config.sh**: Run twice, confirm second run says "already up to date"
- [ ] **node.sh**: Run and confirm it installs LTS version, not version 22 specifically
- [ ] **All installers**: Run with packages already installed, confirm dpkg check works

## Testing

Per project rules, do NOT test locally. Push changes to GitHub and test in a pristine Ubuntu Server VM using:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/FredLackey/dotfiles/main/src/setup.sh)"
```

---

## Summary of macOS Patterns to Follow

| Pattern | macOS Approach | Apply to Ubuntu-Server |
|---------|---------------|----------------------|
| Dependency failure | `exit 1` with "Error:" message | Always fail fast |
| Already installed | Just exit, no side effects | No auto-updates |
| Idempotency check | Check before acting | Verify symlinks point correctly |
| Version selection | `--lts` flag | Use dynamic versioning |
| Package validation | `command -v` + `brew list` | `command -v` + `dpkg -l` |
