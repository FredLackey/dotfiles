# Implementation Plan: Multi-Environment Support Changes

**Objective**: Restructure the repository to isolate environment-specific assets and clean up the root directory. This involves creating a new folder structure, moving scripts, and updating the entry point logic to route to the correct environment setup.

**Prerequisites**:
- Familiarize yourself with the existing script logic in `src/`.

---

## Step 1: Create Folder Structure

Create the following directory structure inside the `src/` folder. This will house all the environment-specific setup scripts.

- `src/os/`
    - `macos/`
    - `ubuntu-desktop/`
    - `ubuntu-server/`
    - `windows/`
    - `ubuntu-wsl/`

**Action**: Run `mkdir -p src/os/{macos,ubuntu-desktop,ubuntu-server,windows,ubuntu-wsl}`

---

## Step 2: Relocate and Rename Environment Scripts

Move the existing environment scripts from `src/` to their new locations in `src/os/`. Rename each script to a standard entry point filename (`setup.sh` for Unix-like, `setup.ps1` for Windows).

| Source File | Destination |
| :--- | :--- |
| `src/setup_macos.sh` | `src/os/macos/setup.sh` |
| `src/setup_ubuntu-desktop.sh` | `src/os/ubuntu-desktop/setup.sh` |
| `src/setup_ubuntu-server.sh` | `src/os/ubuntu-server/setup.sh` |
| `src/setup_ubuntu-wsl.sh` | `src/os/ubuntu-wsl/setup.sh` |
| `src/setup_windows.ps1` | `src/os/windows/setup.ps1` |

**Action**: Use `git mv` or standard move commands to relocate these files.

---

## Step 3: Relocate Root Entry Scripts

Move the main entry point scripts from the root directory into the `src/` folder.

| Source File | Destination |
| :--- | :--- |
| `./setup.sh` | `src/setup.sh` |
| `./setup.ps1` | `src/setup.ps1` |

**Action**: Move these two files.

---

## Step 4: Update Entry Script Logic

The entry scripts (`src/setup.sh` and `src/setup.ps1`) currently might contain logic or just point to old locations. They need to be updated to intelligently route execution to the correct environment script.

### 4.1 Update `src/setup.sh`
Modify `src/setup.sh` to:
1.  Detect the operating system (macOS vs. Linux).
2.  If Linux, attempt to distinguish between WSL, Desktop, or Server (if possible, or default to a safe choice/ask user).
3.  Source or execute the corresponding script in `src/os/<environment>/setup.sh`.

**Logic Stub**:
```bash
# ... existing shebang ...

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS..."
    source "$(dirname "$0")/os/macos/setup.sh"
elif grep -q Microsoft /proc/version; then
    echo "Detected Windows WSL..."
    source "$(dirname "$0")/os/ubuntu-wsl/setup.sh"
# Add logic for Ubuntu Desktop/Server detection here
else
    echo "Unsupported or unknown environment."
    exit 1
fi
```

### 4.2 Update `src/setup.ps1`
Modify `src/setup.ps1` to:
1.  Verify execution on Windows.
2.  Invoke `src/os/windows/setup.ps1`.

---

## Step 5: Update Documentation

The `README.md` file currently points users to run the script from the root.

**Action**:
- Edit `README.md`.
- Find the **Installation** section.
- Update the curl/execution command to point to `src/setup.sh` (or tell the user to run `src/setup.sh` if they cloned the repo).
    - *Note*: If the user is using `curl` to pipe to bash, ensure the URL in the readme is updated to point to `src/setup.sh` relative to the raw GitHub URL.

---

## Step 6: Verification

**Manual Testing**:
1.  **macOS**: Run `src/setup.sh` on a Mac. Verify it calls `src/setup/macos/setup.sh`.
2.  **WSL**: Run `src/setup.sh` in WSL. Verify it calls `src/setup/windows-wsl/setup.sh`.
3.  **Windows**: Run `src/setup.ps1` in PowerShell. Verify it calls `src/setup/windows/setup.ps1`.
4.  **Directory Check**: Ensure no execution scripts remain in the root directory (excluding `setup.sh`/`setup.ps1` if they were meant to stay there, but per requirements they move to `src/`).

---
