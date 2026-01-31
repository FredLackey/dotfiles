# OS Folder and File Structure Rules

This document defines the folder and file structure pattern for all OS-specific setups under `src/os/`. The macOS implementation serves as the reference implementation.

## Directory Structure

Each OS folder must contain exactly these four subdirectories plus a root orchestrator:

```
src/os/{os-name}/
├── setup.sh              # Root orchestrator (setup.ps1 for Windows)
├── files/                # Static configuration files to be deployed
├── functions/            # User-defined shell functions
├── installers/           # Application and tool installation scripts
└── preferences/          # System preference/configuration scripts
```

## Root Orchestrator (setup.sh)

The root `setup.sh` is the single entry point that coordinates the entire OS setup.

**Responsibilities:**
- Call installers in correct dependency order
- Reload shell environments after installing tools that modify PATH (e.g., Homebrew, NVM)
- Call preferences/setup.sh after all installers complete
- Suppress tool-specific cleanup until the end (e.g., `HOMEBREW_NO_INSTALL_CLEANUP=1`)

**Pattern:**
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_installer() {
    local script="$SCRIPT_DIR/installers/$1"
    if [ -f "$script" ]; then
        echo "Running installer: $1"
        bash "$script"
    fi
}

apply_preferences() {
    if [ -f "$SCRIPT_DIR/preferences/setup.sh" ]; then
        bash "$SCRIPT_DIR/preferences/setup.sh"
    fi
}

# Run installers in dependency order
run_installer "prerequisite-tool.sh"
# ... reload environment if needed ...
run_installer "dependent-tool.sh"

# Apply system preferences
apply_preferences

echo "Setup complete."
```

## Files Directory

**Purpose:** Store static configuration files that will be copied or symlinked to their destinations.

**Contents:**
- Shell dotfiles (`.zshrc`, `.bashrc`, `.bash_profile`, `.inputrc`)
- Tool configuration files (`starship.toml`, etc.)
- Color/theme definitions (`bash_colors.sh`, etc.)
- Terminal/editor themes in subdirectories (`terminal/`, etc.)

**Naming Conventions:**
- Dotfiles: Use standard Unix names (`.zshrc`, `.bashrc`)
- Config files: Use tool's expected filename (`starship.toml`)
- Theme files: Descriptive names matching the theme (`Solarized Dark.terminal`)

**Rules:**
1. Files here are never executed directly
2. Installers in `installers/` are responsible for deploying these files
3. Subdirectories allowed for grouping related files (e.g., `terminal/` for terminal themes)

## Functions Directory

**Purpose:** Store user-defined shell functions that provide custom commands.

**Structure:**
```
functions/
├── README.md         # Documentation explaining available functions
├── bash/             # Bash-specific function implementations
│   ├── main.sh       # Loader script that sources all functions
│   └── *.sh          # Individual function files
└── zsh/              # Zsh-specific function implementations
    ├── main.sh       # Loader script that sources all functions
    └── *.sh          # Individual function files
```

**Naming Conventions:**
- Files: `{function-name}.sh` using lowercase with hyphens
- Examples: `git-clone.sh`, `backup-all.sh`, `org-by-date.sh`

**Rules:**
1. Each function lives in its own file
2. Bash and Zsh directories mirror each other with shell-specific syntax
3. `main.sh` in each shell directory sources all other files
4. Shell dotfiles in `files/` source `functions/{shell}/main.sh`
5. Function names should match the filename (without `.sh`)

## Installers Directory

**Purpose:** Install applications, tools, and deploy configuration files.

**Contents:**
- One script per tool/application
- `installers.md` documenting all available installers

**Naming Conventions:**
- Format: `{tool-name}.sh` using lowercase with hyphens
- Use the common/official tool name
- Examples: `homebrew.sh`, `vscode.sh`, `npm-check-updates.sh`, `xcode-command-line-tools.sh`

**Categories (for organization reference):**
1. System prerequisites (package managers, CLI tools)
2. Shell and prompt (shell config, starship, fonts)
3. Language runtimes (nvm, node, go, python)
4. Infrastructure/DevOps (git, terraform, aws-cli, docker)
5. CLI utilities (jq, yq, ffmpeg, imagemagick)
6. Editors and IDEs (vscode, cursor, sublime-text)
7. GUI applications (slack, browsers, utilities)

**Idempotent Script Pattern (REQUIRED):**
```bash
#!/bin/bash
set -e

APP_NAME="ToolName"

# 1. CHECK - Skip if already installed
if command -v tool >/dev/null 2>&1; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. DEPENDENCIES - Verify prerequisites exist
if ! command -v required-tool >/dev/null 2>&1; then
    echo "Error: required-tool is required but not installed."
    exit 1
fi

# 3. INSTALL - Perform the installation
echo "Installing $APP_NAME..."
# installation commands here

# 4. VERIFY - Confirm installation succeeded
if command -v tool >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
```

**Rules:**
1. Every installer must be idempotent (safe to run multiple times)
2. Every installer must follow the 4-step pattern: Check, Dependencies, Install, Verify
3. Use `exit 0` when already installed (success, not an error)
4. Use `exit 1` for actual failures
5. Check for commands using `command -v tool >/dev/null 2>&1`
6. Check for files/directories using `[ -f "/path" ]` or `[ -d "/path" ]`
7. Never assume another installer has run unless explicitly checking

## Preferences Directory

**Purpose:** Configure system preferences and settings.

**Structure:**
```
preferences/
├── setup.sh          # Orchestrator that calls individual preference scripts
└── *.sh              # Individual preference area scripts
```

**Naming Conventions:**
- Format: `{feature-area}.sh` using lowercase with hyphens
- Examples: `dock.sh`, `finder.sh`, `hot-corners.sh`, `menu-bar.sh`

**Idempotent Preference Pattern (REQUIRED):**
```bash
#!/bin/bash
set -e

PREF_NAME="Feature Name"
NEEDS_RESTART=false

# Helper function to set preference only if different
set_pref() {
    local current new_value
    # ... check current value ...
    # ... only write if different ...
    # ... set NEEDS_RESTART=true if changed ...
}

# Apply preferences
set_pref "setting1" "value1"
set_pref "setting2" "value2"

# Restart affected service only if changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall AffectedService 2>/dev/null || true
fi

echo "$PREF_NAME preferences applied."
```

**Rules:**
1. Every preference script must be idempotent
2. Only modify settings if the current value differs
3. Track whether changes were made
4. Only restart services if changes were applied
5. Group related preferences in the same file
6. `setup.sh` orchestrates all preference scripts

## OS-Specific Variations

### Linux (ubuntu-desktop, ubuntu-server, ubuntu-wsl)
- Use `apt` or package managers instead of Homebrew
- Preferences may use `gsettings`, `dconf`, or config files instead of `defaults`
- WSL may have Windows-specific integration considerations

### Windows
- Use `setup.ps1` instead of `setup.sh`
- Installers use PowerShell scripts (`.ps1`)
- Use `winget`, `choco`, or `scoop` as package managers
- Preferences use Registry, Group Policy, or Settings APIs

## Checklist for New OS Implementation

- [ ] Create root `setup.sh` (or `setup.ps1` for Windows)
- [ ] Create `files/` directory with shell dotfiles and configs
- [ ] Create `functions/` directory with shell-specific subdirectories
- [ ] Create `functions/{shell}/main.sh` loader for each supported shell
- [ ] Create `installers/` directory
- [ ] Create `installers/installers.md` documenting available installers
- [ ] Create `preferences/` directory
- [ ] Create `preferences/setup.sh` orchestrator
- [ ] Ensure all scripts follow the idempotent pattern
- [ ] Test in a pristine VM (never test locally)
