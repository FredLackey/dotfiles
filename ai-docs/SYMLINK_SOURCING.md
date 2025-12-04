# Shell File Symlink and Sourcing Architecture

This document explains how shell configuration files are symlinked and sourced, and documents a known issue with the `create_symbolic_links.sh` script.

---

## The Problem

**Symptom:** Common aliases like `q` (exit) don't work on macOS, even though they're defined in `src/shell/bash_aliases`.

**Root Cause:** The `create_symbolic_links.sh` script uses `get_shell_source()` which prefers OS-specific files when they exist. This causes `~/.bash_aliases` to symlink directly to `src/shell/macos/bash_aliases`, bypassing the base file where common aliases are defined.

**Example of incorrect symlink:**
```
~/.bash_aliases → src/shell/macos/bash_aliases  (WRONG)
```

**Correct symlink:**
```
~/.bash_aliases → src/shell/bash_aliases  (CORRECT)
```

---

## Sourcing Chain Architecture

The shell configuration uses a layered sourcing approach:

```
┌─────────────────────────────────────────────────────────────────┐
│ ~/.bash_profile (→ src/shell/bash_profile)                      │
│   1. cd to src/shell/                                           │
│   2. source ../os/utils.sh                                      │
│   3. OS="$(get_os_name)"  # e.g., "macos"                       │
│   4. source ~/.bash_aliases                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ ~/.bash_aliases (→ src/shell/bash_aliases) [BASE FILE]          │
│   - Defines common aliases: q, c, ll, g, etc.                   │
│   - Line 47: . "$OS/bash_aliases"  # Sources OS-specific        │
│   - Defines more aliases: tpo, tpa, count-*, etc.               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ src/shell/macos/bash_aliases [OS-SPECIFIC FILE]                 │
│   - Defines macOS-only aliases: afk, brew*, o, u, etc.          │
│   - Does NOT source any other files                             │
│   - Returns to base file when done                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Why There's No Infinite Loop

A concern was raised about circular sourcing. Here's why it doesn't happen:

1. **Base file uses relative path:** Line 47 in base `bash_aliases`:
   ```bash
   . "$OS/bash_aliases"
   ```
   With `$OS="macos"`, this becomes `. "macos/bash_aliases"`

2. **Current directory is `src/shell/`:** The `bash_profile` does `cd` to `src/shell/` before sourcing begins, so the relative path resolves to `src/shell/macos/bash_aliases`

3. **OS-specific file has no source commands:** The `macos/bash_aliases` file only contains alias definitions - it does NOT source `~/.bash_aliases` or any other file

4. **Path resolution:**
   - `~/.bash_aliases` → `src/shell/bash_aliases` (symlink)
   - `macos/bash_aliases` → `src/shell/macos/bash_aliases` (relative path)
   - These are different files, so no loop occurs

---

## The Bug in create_symbolic_links.sh

Location: `src/os/create_symbolic_links.sh`, lines 31-38

```bash
get_shell_source() {
    local filename="$1"
    if [ -f "$baseDir/shell/$os_name/$filename" ]; then
        printf "%s" "shell/$os_name/$filename"  # Prefers OS-specific
    else
        printf "%s" "shell/$filename"           # Falls back to base
    fi
}
```

**Problem:** This function assumes OS-specific files are complete replacements. But for `bash_aliases`, the base file is designed to source the OS-specific file internally (line 47), not be replaced by it.

**Affected files:** Any shell config file that:
1. Has an OS-specific variant, AND
2. Internally sources that variant via `. "$OS/filename"`

Currently affected:
- `bash_aliases` (line 47: `. "$OS/bash_aliases"`)
- `bash_autocompletion` (line 7: `. "$OS/bash_autocompletion"`)
- `bash_init` (line 7: `. "$OS/bash_init"`)

---

## Manual Fix

To fix the symlink manually:

```bash
ln -sf ~/projects/dotfiles/src/shell/bash_aliases ~/.bash_aliases
```

Then reload:
```bash
source ~/.bash_profile
```

---

## Permanent Fix (Applied)

The `get_shell_source()` function in `src/os/create_symbolic_links.sh` has been updated to exclude files that self-source OS variants:

```bash
get_shell_source() {
    local filename="$1"

    # These files source OS-specific variants internally via `. "$OS/filename"`
    # and must always symlink to the base file to avoid bypassing common config.
    local -a self_sourcing_files=(
        "bash_aliases"
        "bash_autocompletion"
        "bash_init"
    )

    for f in "${self_sourcing_files[@]}"; do
        if [ "$filename" = "$f" ]; then
            printf "%s" "shell/$filename"
            return
        fi
    done

    if [ -f "$baseDir/shell/$os_name/$filename" ]; then
        printf "%s" "shell/$os_name/$filename"
    else
        printf "%s" "shell/$filename"
    fi
}
```

**When adding new shell config files:** If the base file sources its OS-specific variant internally via `. "$OS/filename"`, add the filename to the `self_sourcing_files` array.

---

## Files Reference

| File | Location | Symlink Target |
|------|----------|----------------|
| bash_aliases (base) | `src/shell/bash_aliases` | Should be `~/.bash_aliases` |
| bash_aliases (macOS) | `src/shell/macos/bash_aliases` | Sourced by base file |
| bash_aliases (Ubuntu) | `src/shell/ubuntu-*/bash_aliases` | Sourced by base file |
| bash_profile | `src/shell/bash_profile` | `~/.bash_profile` |
| bashrc | `src/shell/bashrc` | `~/.bashrc` |

---

## Verification Commands

Check current symlink:
```bash
ls -la ~/.bash_aliases
```

Verify alias is loaded:
```bash
type q
alias q
```

Test sourcing chain (dry run):
```bash
bash -x -c 'source ~/.bash_profile' 2>&1 | grep -E 'bash_aliases|^\\+'
```
