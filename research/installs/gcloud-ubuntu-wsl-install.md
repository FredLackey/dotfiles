# Google Cloud CLI (gcloud) - Ubuntu WSL Installation

## Tool Summary

| Field | Value |
|---|---|
| **Tool** | Google Cloud CLI (`gcloud`) |
| **Description** | Command-line interface for Google Cloud Platform — manage resources, deploy apps, configure services, and authenticate with GCP |
| **Official Docs** | https://cloud.google.com/sdk/docs/install |
| **License** | Apache 2.0 |
| **Language** | Python |
| **Ubuntu WSL Available** | Yes (apt with Google's package repository) |

## What It Does

The Google Cloud CLI is the primary command-line tool for interacting with Google Cloud Platform. It lets you create and manage GCP resources (Compute Engine VMs, Cloud Storage buckets, BigQuery datasets, Kubernetes clusters, etc.), deploy applications, configure IAM permissions, and handle authentication from the terminal.

The base apt package includes:

- `gcloud` — core CLI for GCP resource management
- `gcloud alpha` / `gcloud beta` — preview and pre-release commands
- `gsutil` — Cloud Storage file operations (upload, download, sync, manage buckets)
- `bq` — BigQuery command-line tool for queries and dataset management

It does not include `kubectl` or App Engine extensions. Those are installed separately (see Optional Components below).

## Prerequisites

- **Ubuntu on WSL 2** — any Ubuntu release that hasn't reached end-of-life
- **Python 3.10 to 3.14** — the apt package handles this dependency, but worth confirming
- **curl** — needed to fetch the signing key
- **apt-transport-https** — needed for HTTPS package sources
- **gnupg** — needed to handle the GPG signing key
- A Google Cloud account with at least one project

## Installation (apt with Google's Repository - Recommended)

This is the officially recommended method for Debian/Ubuntu systems, including WSL.

```bash
# 1. Install prerequisite packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

# 2. Import Google Cloud's public signing key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# 3. Add the Google Cloud SDK repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# 4. Update package list and install the CLI
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# 5. Verify the installation
gcloud version
```

**Important:** Make sure you don't end up with duplicate entries in `/etc/apt/sources.list.d/google-cloud-sdk.list` if you run step 3 more than once. The `tee -a` appends, so re-running it will add a duplicate line. Check the file if something looks off during `apt-get update`.

## Verification

```bash
# Check the installed version
gcloud version

# Confirm it's in your PATH
which gcloud

# List available commands
gcloud help

# Check current configuration (will be empty before init)
gcloud config list
```

## Post-Install Configuration

### 1. Initialize the CLI

```bash
gcloud init --no-launch-browser
```

Use the `--no-launch-browser` flag because WSL cannot reliably open Windows browsers via localhost redirect (see WSL-Specific Notes below). The command will print a URL. Copy it, paste it into a browser on the Windows side, complete the OAuth flow, then paste the authorization code back into the terminal.

This will prompt you to:

- Log in with your Google account
- Select a default GCP project
- Optionally set a default Compute Engine region/zone

### 2. Verify authentication

```bash
# Check who you're authenticated as
gcloud auth list

# Check your active project
gcloud config get-value project
```

### 3. Application Default Credentials (for local development)

If you're building apps that call GCP APIs using client libraries, you also need Application Default Credentials:

```bash
gcloud auth application-default login --no-launch-browser
```

Same browser flow as above. This writes credentials to `~/.config/gcloud/application_default_credentials.json`, which GCP client libraries pick up automatically.

## Optional Components

These are installed through the same apt repository:

```bash
# kubectl for Kubernetes / GKE
sudo apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin
# Then install kubectl itself:
sudo apt-get install -y kubectl

# App Engine extensions
sudo apt-get install -y google-cloud-cli-app-engine-python
sudo apt-get install -y google-cloud-cli-app-engine-java
sudo apt-get install -y google-cloud-cli-app-engine-go

# Cloud Firestore emulator
sudo apt-get install -y google-cloud-cli-firestore-emulator

# Pub/Sub emulator
sudo apt-get install -y google-cloud-cli-pubsub-emulator

# Bigtable emulator
sudo apt-get install -y google-cloud-cli-bigtable-emulator
```

You can also list available components with:

```bash
gcloud components list
```

Note: When gcloud is installed via apt, use `apt-get install` for additional components rather than `gcloud components install`, which is disabled for package-manager installs.

## WSL-Specific Notes

### Browser authentication does not work out of the box

The default `gcloud auth login` flow tries to start a local HTTP server on `localhost:8085` and redirect the browser to it after OAuth. In WSL, this fails for two reasons:

1. WSL cannot reliably launch the Windows browser automatically
2. Even if the browser opens, the `localhost` redirect targets the Windows side, but the listener is on the WSL side. Port forwarding between WSL and Windows is not guaranteed, and the port may already be in use

**Always use `--no-launch-browser`** for any auth command. This gives you a URL to copy-paste into a browser manually and returns an authorization code to paste back.

```bash
gcloud auth login --no-launch-browser
gcloud auth application-default login --no-launch-browser
```

### Install in WSL, not on the Windows side

If you do most of your development inside WSL, install gcloud inside WSL only. Do not install the Windows version alongside it. Running two installations means two separate configurations, two authentication states, and two versions to keep in sync. They will diverge and cause confusion. Pick one and stick with it.

If you need gcloud from PowerShell or CMD on the Windows side for a different workflow, that's a separate install with its own configuration. They do not share state.

### Configuration file location

gcloud stores its configuration in `~/.config/gcloud/` inside the WSL filesystem. This is completely separate from any Windows-side gcloud installation at `%APPDATA%\gcloud\`.

### Snap is not recommended in WSL

While gcloud is available as a snap package, snap does not work reliably in WSL due to systemd limitations. Use the apt method described above.

### SSH and gcloud compute ssh

`gcloud compute ssh` generates and manages SSH keys for connecting to Compute Engine VMs. In WSL, this works fine but the keys are stored in `~/.ssh/` inside WSL, not the Windows-side `~/.ssh`. If you need to access the same VMs from both Windows and WSL, you'll need to manage keys separately or share the `.ssh` directory (which has its own permission complications).

## Useful Commands Quick Reference

| Command | Description |
|---|---|
| `gcloud auth login --no-launch-browser` | Authenticate with Google Cloud |
| `gcloud auth list` | List authenticated accounts |
| `gcloud config set project PROJECT_ID` | Set active project |
| `gcloud config list` | Show current configuration |
| `gcloud projects list` | List accessible projects |
| `gcloud compute instances list` | List Compute Engine VMs |
| `gcloud components list` | List available/installed components |
| `gcloud auth revoke` | Remove stored credentials |
| `gcloud config configurations create NAME` | Create a named config profile |
| `gcloud config configurations activate NAME` | Switch between config profiles |

## Updating

Since gcloud is installed via apt, update it with your normal package manager workflow:

```bash
sudo apt-get update && sudo apt-get upgrade google-cloud-cli
```

## Uninstalling

```bash
sudo apt-get remove --purge google-cloud-cli
sudo rm /etc/apt/sources.list.d/google-cloud-sdk.list
sudo rm /usr/share/keyrings/cloud.google.gpg

# Remove user configuration
rm -rf ~/.config/gcloud
```
