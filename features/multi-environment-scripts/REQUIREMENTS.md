# Multi-Environment Shell Scripts

## Problem Statement

Shell function files in this repository use `#!/bin/bash` shebangs but are **sourced** (not executed) into the user's shell environment. When a file is sourced, the shebang is completely ignored—the code runs in whatever shell interpreter sources it.

This creates a critical issue: **macOS defaults to zsh**, but our function files contain bash-specific syntax that fails or behaves incorrectly when sourced into zsh.

## Current State

- Function files exist in `src/os/macos/functions/` with `#!/bin/bash` shebangs
- These files are intended to be sourced into the user's shell (`.bashrc` or `.zshrc`)
- The shebangs provide no protection—they are decorative when sourcing
- Bash-specific syntax silently fails or produces unexpected results in zsh

## Affected Syntax

The following bash constructs do not work correctly when sourced into zsh:

| Bash Syntax | Issue in Zsh |
|-------------|--------------|
| `read -p "prompt" var` | `-p` means "read from coprocess" in zsh—completely different behavior |
| `${arr[0]}` (first element) | Zsh arrays are 1-indexed by default; returns empty |
| `$BASH_REMATCH` | Zsh uses `$MATCH` / `$match` for regex captures |
| `${!var}` (indirect expansion) | Syntax error; zsh uses `${(P)var}` |
| `mapfile` / `readarray` | Does not exist in zsh |

### Known Affected Functions

- `docker-clean.sh` uses `read -p "Are you sure?" -n 1 -r` which fails in zsh

## Requirements

### R1: Shell-Appropriate Function Execution

Functions must execute correctly in their target shell environment. A function sourced into bash must use bash-compatible syntax. A function sourced into zsh must use zsh-compatible syntax.

### R2: Platform Coverage

The solution must support all platforms in this repository:

- **macOS**: bash and zsh (zsh is default since Catalina)
- **Ubuntu Desktop**: bash (possibly zsh)
- **Ubuntu Server**: bash
- **Ubuntu WSL**: bash and zsh
- **Windows**: PowerShell, cmd, Git Bash (separate concern—PowerShell scripts already exist)

### R3: Architectural Consistency

The solution should align with the existing repository architecture, which already maintains separate code paths per operating system under `src/os/`.

### R4: Idempotent Setup

Per repository rules, the setup process that sources these functions must remain idempotent:
1. Check if functions need to be loaded
2. Load functions for the appropriate shell
3. Verify functions are available

### R5: Maintainability

- Functions must be clear enough for junior developers to understand
- The relationship between shell type and function location must be obvious
- Adding new functions should follow a predictable pattern

### R6: No Silent Failures

Functions must not silently fail or produce incorrect behavior. If a function cannot run in the current shell, it should either:
- Not be loaded at all, or
- Fail explicitly with a clear error message

## Success Criteria

1. All existing functions work correctly when sourced into bash
2. All existing functions (or their equivalents) work correctly when sourced into zsh on macOS
3. New functions can be added following a documented, consistent pattern
4. The setup process correctly identifies the user's shell and loads appropriate functions
5. No bash-specific syntax is sourced into zsh (and vice versa)

## Out of Scope

- Windows PowerShell scripts (already handled separately)
- Converting all functions to POSIX-only syntax (acceptable but not required)
- Supporting shells beyond bash and zsh (sh, dash, fish, etc.)
