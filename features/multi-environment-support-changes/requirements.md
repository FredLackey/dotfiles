# Multi-Environment Support Changes Requirements

## Overview
The current repository structure places setup scripts in the root and mixed within the `src/` folder. This approach is becoming cluttered and inefficient as we look to add more environment-specific files. We need to restructure the project to isolate environment assets and clean up the root directory.

## Structural Changes

### 1. New `setup` Directory
- Create a new folder: `src/setup/`.
- Within `src/setup/`, create a dedicated subdirectory for each target environment (e.g., `macos`, `windows-wsl`, etc.).

### 2. Relocation of Environment Scripts
Move the specific environment setup scripts from `src/` into their respective folders within `src/setup/` and rename them to a standard entry point (e.g., `setup.sh` or `setup.ps1`).

**Proposed Mapping:**
- `src/setup_macos.sh` &rarr; `src/setup/macos/setup.sh`
- `src/setup_ubuntu-wsl.sh` &rarr; `src/setup/windows-wsl/setup.sh`
- `src/setup_ubuntu-desktop.sh` &rarr; `src/setup/ubuntu-desktop/setup.sh`
- `src/setup_ubuntu-server.sh` &rarr; `src/setup/ubuntu-server/setup.sh`
- `src/setup_windows.ps1` &rarr; `src/setup/windows/setup.ps1`

### 3. Relocation of Root Entry Scripts
- Move the root `setup.sh` to `src/setup.sh`.
- Move the root `setup.ps1` to `src/setup.ps1`.
- Clean up the root directory so it does not contain execution scripts.

## Logic Updates

### Entry Script Routing
- The entry scripts moved to `src/` (`setup.sh` and `setup.ps1`) must be updated to handle the logic previously handled by distinct filenames.
- They must identify the target environment.
- Based on the identification, they must invoke the appropriate child script located in `src/setup/<environment>/setup.*`.

### User Invocation
- Users will now invoke the setup script via the `src/` path (e.g., executing `src/setup.sh` instead of just `setup.sh` from the root).

## Documentation Updates

### README.md
- Update the installation instructions to reflect the new path of the setup script (`src/setup.sh` and `src/setup.ps1` instead of `setup.sh` and `setup.ps1`).
