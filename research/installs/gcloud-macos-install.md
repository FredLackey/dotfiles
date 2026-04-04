# Google Cloud CLI (gcloud) - macOS Installation

## Overview

| Field | Value |
|---|---|
| Tool Name | Google Cloud CLI (`gcloud`) |
| Publisher | Google |
| Description | Command-line interface for managing Google Cloud resources and services. Part of the Google Cloud SDK, which also includes `gsutil` (Cloud Storage) and `bq` (BigQuery). |
| macOS Available | Yes |
| Current Version | 563.0.0 (as of April 2026) |
| Official Docs | https://cloud.google.com/sdk/docs |
| Install Guide | https://cloud.google.com/sdk/docs/install-sdk |
| Homebrew Cask | `gcloud-cli` (community-maintained) |

## What Is Included

The Google Cloud SDK installs three main command-line tools:

- **`gcloud`** - Primary CLI for Google Cloud. Manages compute instances, networking, IAM, deployments, and most GCP services.
- **`gsutil`** - Interact with Google Cloud Storage buckets and objects.
- **`bq`** - Query and manage BigQuery datasets and tables.

Additional components (kubectl, App Engine extensions, etc.) can be added later with `gcloud components install`.

## Prerequisites

- macOS 10.15 (Catalina) or later
- Intel (x86_64) or Apple Silicon (ARM64)
- Python 3.10 through 3.14 (the installer will deploy Python 3.13 automatically if a compatible version is not found)
- Homebrew (if using the Homebrew installation method)

## Installation

### Option 1: Homebrew Cask (Recommended for Homebrew Users)

This is the simplest method if you already use Homebrew to manage your tools.

```bash
# Update Homebrew and install gcloud CLI
brew update && brew install --cask gcloud-cli
```

After installation, add the SDK binaries to your PATH. Add this to your `~/.zshrc` (or `~/.bash_profile` for Bash):

```bash
# Google Cloud SDK (Homebrew)
export PATH="$(brew --prefix)/share/google-cloud-sdk/bin:$PATH"
```

Then source shell completions (optional but helpful). Add to `~/.zshrc`:

```bash
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
```

Or for Bash, add to `~/.bash_profile`:

```bash
source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.bash.inc"
```

Reload your shell:

```bash
source ~/.zshrc
```

To update later:

```bash
gcloud components update
```

To uninstall:

```bash
brew uninstall --cask gcloud-cli
```

### Option 2: Official Google Installer

This is Google's own installer script. It handles Python detection, PATH modification, and shell completion setup through an interactive wizard. Use this method if you hit Python path issues with Homebrew or prefer Google's supported install path.

For **Apple Silicon** (M1/M2/M3/M4):

```bash
cd ~
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz
tar -xf google-cloud-cli-darwin-arm.tar.gz
./google-cloud-sdk/install.sh
```

For **Intel** Macs:

```bash
cd ~
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz
tar -xf google-cloud-cli-darwin-x86_64.tar.gz
./google-cloud-sdk/install.sh
```

The installer will prompt you to:

1. Install Python 3.13 if a compatible version is not detected
2. Add gcloud to your PATH and enable shell completion
3. Opt into anonymous usage statistics (optional)

After the installer finishes, open a new terminal window for PATH changes to take effect.

To update later:

```bash
gcloud components update
```

To uninstall:

```bash
rm -rf ~/google-cloud-sdk
```

And remove the sourced lines from your shell profile.

## Verification

```bash
gcloud --version
```

Expected output (version numbers will vary):

```
Google Cloud SDK 563.0.0
bq 2.x.x
core 2026.x.x
gsutil 5.x
```

Additional verification commands:

```bash
# Confirm binary location
which gcloud

# Show full environment info (SDK root, Python version, PATH, active config)
gcloud info

# List credentialed accounts (empty until you run gcloud init)
gcloud auth list
```

## Post-Install Configuration

### Initialize gcloud

Run this after installation to authenticate and set default project/region:

```bash
gcloud init
```

This opens a browser window for Google account OAuth. After authenticating, it prompts you to select a default project and compute region/zone. If you are on a headless machine (SSH session, no browser), use:

```bash
gcloud init --console-only
```

### Check Active Configuration

```bash
gcloud config list
```

### Install Additional Components

Common components you might need:

```bash
# Kubernetes CLI
gcloud components install kubectl

# App Engine extensions
gcloud components install app-engine-python

# List all available components
gcloud components list
```

## Homebrew vs Official Installer

| | Homebrew Cask | Official Installer |
|---|---|---|
| Maintained by | Homebrew community | Google |
| Install command | `brew install --cask gcloud-cli` | `./install.sh` |
| Python handling | Depends on Homebrew's `python@3.13` formula | Bundles/detects Python automatically |
| PATH setup | Manual (add to shell profile) | Interactive prompt during install |
| Shell completions | Manual (source the `.inc` files) | Interactive prompt during install |
| Update method | `gcloud components update` | `gcloud components update` |
| Known issues | Python path conflicts on some setups; community reports of broken symlinks after Homebrew Python upgrades | None significant; designed to handle edge cases |
| Best for | Developers who manage everything through Homebrew | Anyone who wants the most reliable, Google-supported path |

**Recommendation**: Homebrew works well for most developers and keeps gcloud alongside your other tools. If you run into Python-related errors after installation (especially after a Homebrew Python upgrade), switch to the official installer. The official installer has better logic for detecting and adapting to your actual Python environment.

## PATH Notes

- **Homebrew**: Installs to `$(brew --prefix)/share/google-cloud-sdk/`. The main `gcloud` binary is symlinked into Homebrew's bin, but additional tools (`gsutil`, `bq`, `anthoscli`, etc.) live in the SDK's own `bin/` directory. You must add that directory to PATH manually.
- **Official installer**: Installs to `~/google-cloud-sdk/` by default (wherever you extract the tarball). The install script offers to modify your shell profile to add the SDK to PATH automatically.
- Both methods install shell completion scripts that must be sourced from your shell profile for tab completion to work.

## Sources

- https://cloud.google.com/sdk/docs/install-sdk
- https://docs.cloud.google.com/sdk/docs/downloads-homebrew
- https://formulae.brew.sh/cask/gcloud-cli
