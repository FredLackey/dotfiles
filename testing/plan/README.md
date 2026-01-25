# Docker Testing Plan for Dotfiles

This document explains how to test the dotfiles installation scripts using Docker containers. Docker allows us to simulate fresh machines without needing actual VMs.

## Overview

We use Docker to create isolated, reproducible environments that simulate fresh installations of each supported operating system. After each test, we destroy the container and start fresh—ensuring our scripts work on clean machines every time.

## Supported Test Environments

| Environment | Docker Image | Can Test? | Notes |
|-------------|--------------|-----------|-------|
| Ubuntu Server | `ubuntu:22.04` | Yes | Full CLI testing |
| Ubuntu Desktop | `ubuntu:22.04` | Partial | CLI only (no GUI) |
| Ubuntu WSL | `ubuntu:22.04` | Simulated | Fakes WSL environment variables |
| macOS | N/A | No | Use actual VM instead |
| Windows | N/A | No | Use actual VM instead |

**Why can't we test macOS/Windows?**
- macOS cannot legally run in Docker (Apple licensing)
- Windows containers are complex and don't match real desktop behavior
- For these platforms, use VirtualBox, Parallels, or cloud VMs

## Folder Structure

```
testing/
├── plan/
│   └── README.md              # This file
├── docker/
│   ├── ubuntu-server.Dockerfile
│   ├── ubuntu-desktop.Dockerfile
│   └── ubuntu-wsl.Dockerfile
└── scripts/
    ├── build.sh               # Build all Docker images
    ├── test.sh                # Run a test for a specific environment
    ├── test-all.sh            # Run tests for all environments
    └── clean.sh               # Remove all test containers and images
```

## How It Works

### The Testing Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                     TESTING WORKFLOW                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   1. BUILD        Create Docker image for environment       │
│        ↓                                                    │
│   2. RUN          Start container and run setup.sh          │
│        ↓                                                    │
│   3. OBSERVE      Watch output for errors                   │
│        ↓                                                    │
│   4. DESTROY      Remove the container completely           │
│        ↓                                                    │
│   5. FIX          Edit problematic scripts (if errors)      │
│        ↓                                                    │
│   6. REPEAT       Go back to step 2 (container is fresh)    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### What Each Docker Container Simulates

**Ubuntu Server Container:**
- Fresh Ubuntu 22.04 with minimal packages
- No `$XDG_CURRENT_DESKTOP` variable (this is how `setup.sh` detects server)
- No WSL markers in `/proc/version`

**Ubuntu Desktop Container:**
- Same as server but with `XDG_CURRENT_DESKTOP=GNOME` set
- Tests the CLI portions of desktop setup (GUI apps can't be tested)

**Ubuntu WSL Container:**
- Sets `WSL_DISTRO_NAME=Ubuntu` environment variable
- Adds "Microsoft" marker to simulate `/proc/version` check
- Tests WSL-specific paths in the setup scripts

## Step-by-Step Instructions

### Prerequisites

Before testing, ensure Docker is installed and running:

```bash
# Check if Docker is installed
docker --version

# Check if Docker daemon is running
docker info
```

### Step 1: Build the Docker Images

Run this once (or after changing Dockerfiles):

```bash
cd ~/.dotfiles
./testing/scripts/build.sh
```

This creates three images:
- `dotfiles-test:ubuntu-server`
- `dotfiles-test:ubuntu-desktop`
- `dotfiles-test:ubuntu-wsl`

### Step 2: Run a Test

To test a specific environment:

```bash
# Test Ubuntu Server
./testing/scripts/test.sh ubuntu-server

# Test Ubuntu Desktop
./testing/scripts/test.sh ubuntu-desktop

# Test Ubuntu WSL
./testing/scripts/test.sh ubuntu-wsl
```

Or test all environments:

```bash
./testing/scripts/test-all.sh
```

### Step 3: Observe the Output

The test script will:
1. Start a fresh container
2. Run the dotfiles setup script (simulating `curl | sh` install)
3. Show all output in your terminal
4. Report SUCCESS or FAILURE

**What to look for:**
- `Error:` messages
- `command not found` errors
- Permission denied errors
- Scripts that hang or timeout

### Step 4: Fix and Retest

If a test fails:

1. **Read the error message** - Note which script failed and why
2. **Edit the problematic file** - Fix the issue in `src/os/<platform>/`
3. **Retest immediately** - The old container is gone; you get a fresh one

```bash
# Example workflow after finding a bug
vim src/os/ubuntu-server/installers/git.sh  # Fix the bug
./testing/scripts/test.sh ubuntu-server      # Test again (fresh container)
```

### Step 5: Clean Up

Remove all test containers and images when done:

```bash
./testing/scripts/clean.sh
```

## Testing Modes

### Interactive Mode

To get a shell inside the container for debugging:

```bash
./testing/scripts/test.sh ubuntu-server --interactive
```

This drops you into a bash shell. You can:
- Manually run `setup.sh` step by step
- Inspect the system state
- Test individual installers

Type `exit` to leave and destroy the container.

### Remote Install Mode (Default)

Simulates what happens when a user runs:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/.../setup.sh)"
```

The container downloads from GitHub (your branch) and runs the full install.

### Local Install Mode

Tests the local files without pushing to GitHub:

```bash
./testing/scripts/test.sh ubuntu-server --local
```

This mounts your local `~/.dotfiles` folder into the container.

**When to use each mode:**
- Use `--local` during development for fast iteration
- Use remote mode (default) before committing to verify GitHub install works

## Writing Testable Scripts

For your scripts to work in Docker testing, follow these rules:

### 1. Never Require User Input

```bash
# BAD - will hang in Docker
read -p "Continue? (y/n) " answer

# GOOD - use defaults or environment variables
CONTINUE=${CONTINUE:-y}
```

### 2. Handle Missing Commands Gracefully

```bash
# BAD - crashes if sudo not available
sudo apt-get update

# GOOD - check first
if command -v sudo >/dev/null; then
    sudo apt-get update
else
    apt-get update  # Might be running as root in Docker
fi
```

### 3. Don't Assume GUI Exists

```bash
# BAD - fails in Docker
open /Applications/MyApp.app

# GOOD - check if GUI is available
if [ -n "$DISPLAY" ] || [ "$(uname)" = "Darwin" ]; then
    open /Applications/MyApp.app
else
    echo "Skipping GUI launch (no display)"
fi
```

## Troubleshooting

### "Cannot connect to Docker daemon"

Docker isn't running. Start it:
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

### "Permission denied" errors in container

The setup script may need sudo. Our Dockerfiles install sudo and configure a test user with passwordless sudo access.

### Test passes in Docker but fails on real machine

Docker containers are minimal. A real machine may have:
- Different default packages installed
- User-specific configurations
- GUI requirements

Always do a final test on a real VM before releasing major changes.

### Scripts work locally but fail in remote mode

Your changes aren't on GitHub yet. Either:
1. Push your branch and test against it
2. Use `--local` mode during development

## Quick Reference

```bash
# Build images (run once)
./testing/scripts/build.sh

# Test specific environment
./testing/scripts/test.sh ubuntu-server
./testing/scripts/test.sh ubuntu-desktop
./testing/scripts/test.sh ubuntu-wsl

# Test all environments
./testing/scripts/test-all.sh

# Interactive debugging
./testing/scripts/test.sh ubuntu-server --interactive

# Test local changes (without pushing to GitHub)
./testing/scripts/test.sh ubuntu-server --local

# Clean up everything
./testing/scripts/clean.sh
```

## Next Steps

1. Run `./testing/scripts/build.sh` to create the Docker images
2. Run `./testing/scripts/test.sh ubuntu-server` to test your first environment
3. Fix any errors, then retest
4. Repeat for all environments before pushing to main branch
