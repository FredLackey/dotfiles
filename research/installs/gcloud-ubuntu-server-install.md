# Google Cloud CLI (gcloud) - Ubuntu Server Installation

## Tool Overview

**Google Cloud CLI** (commonly called `gcloud`) is the primary command-line tool for interacting with Google Cloud Platform (GCP). It lets you manage GCP resources, deploy applications, configure services, and authenticate against Google Cloud APIs -- all from the terminal. The CLI is part of the broader Google Cloud SDK, which also includes helper tools like `gsutil` (Cloud Storage), `bq` (BigQuery), and `kubectl` (Kubernetes).

- **Official docs:** <https://cloud.google.com/sdk/docs>
- **Installation reference:** <https://cloud.google.com/sdk/docs/install#deb>
- **Auth reference:** <https://cloud.google.com/sdk/docs/authorizing>
- **Available for Ubuntu Server:** Yes. Google publishes an apt repository (`cloud-sdk`) that works on any supported Debian or Ubuntu release regardless of whether a desktop environment is present. The same `google-cloud-cli` package works on desktop, server, and WSL.

## Prerequisites

- **Ubuntu Server** that has not reached end-of-life (22.04, 24.04, 26.04, etc.)
- **sudo access** for installing packages and configuring the apt source
- **curl** -- to fetch Google's GPG signing key
- **ca-certificates** -- for HTTPS connections to the repository
- **gnupg** -- to dearmor the GPG key into a keyring file

Install the prerequisites if they are not already present:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
```

No specific Python version is required. The `google-cloud-cli` apt package bundles its own Python runtime.

## Installation Steps

### 1. Import Google Cloud's GPG signing key

This key lets apt verify that packages in the Google Cloud repository are authentic and unmodified.

```bash
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
```

Set permissions so apt can read it:

```bash
sudo chmod 644 /usr/share/keyrings/cloud.google.gpg
```

### 2. Add the Google Cloud apt repository

```bash
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
```

**Note:** The `signed-by=` clause ties this source to the specific GPG key imported above. This is the modern approach (Debian 9+ / Ubuntu 18.04+) and avoids the deprecated `apt-key` method.

### 3. Install the CLI

```bash
sudo apt-get update
sudo apt-get install -y google-cloud-cli
```

This installs the core `gcloud` command along with `gsutil` and `bq`.

### 4. Verify the installation

```bash
gcloud version
```

You should see output showing the Google Cloud SDK version and the versions of bundled components (bq, gsutil, core, etc.).

Also confirm the binary is on your PATH:

```bash
which gcloud
```

Expected output: `/usr/bin/gcloud`

## Post-Install Configuration

### Initializing gcloud

On a headless server (no browser available), run:

```bash
gcloud init --no-browser
```

This starts an interactive setup that:

1. Asks you to log in (see authentication section below)
2. Lets you select or create a GCP project
3. Optionally sets a default compute region/zone

If you want to skip all interactive prompts and configure manually:

```bash
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/region us-east1
gcloud config set compute/zone us-east1-b
```

### Headless Authentication

Since Ubuntu Server has no web browser, you need to authenticate using one of these methods:

#### Option A: `--no-browser` flag (requires gcloud on a second machine)

This is Google's recommended approach. It generates a command you copy and run on another machine that has both gcloud and a web browser.

```bash
gcloud auth login --no-browser
```

The CLI prints a long `gcloud auth login --remote-bootstrap="..."` command. Copy that entire command, run it on a machine with a browser, complete the login in the browser, then paste the resulting output back into the server's terminal.

**Requirement:** The second machine must have gcloud CLI version 372.0 or later installed.

#### Option B: `--no-launch-browser` flag (simpler, any browser)

This prints a URL you open manually in any browser on any device. After authenticating in the browser, you get an authorization code to paste back into the terminal.

```bash
gcloud auth login --no-launch-browser
```

This does not require gcloud on the second machine -- just a browser.

#### Option C: Service account key (automation / CI)

For non-interactive use (scripts, CI pipelines, cron jobs), use a service account:

```bash
gcloud auth activate-service-account --key-file=/path/to/service-account-key.json
```

Create and download the key file from the GCP Console under IAM > Service Accounts.

### Setting application default credentials

Many client libraries and tools use Application Default Credentials (ADC) instead of the gcloud auth session. Set them with:

```bash
gcloud auth application-default login --no-browser
```

Or for a service account:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

## Optional Components

The base `google-cloud-cli` package covers most use cases. Additional components can be installed as separate apt packages:

```bash
# Kubernetes CLI
sudo apt-get install -y google-cloud-cli-kubectl

# App Engine support (Java, Python, Go, etc.)
sudo apt-get install -y google-cloud-cli-app-engine-python
sudo apt-get install -y google-cloud-cli-app-engine-java
sudo apt-get install -y google-cloud-cli-app-engine-go

# Cloud Firestore emulator
sudo apt-get install -y google-cloud-cli-firestore-emulator

# Pub/Sub emulator
sudo apt-get install -y google-cloud-cli-pubsub-emulator
```

List all available components with:

```bash
apt-cache search google-cloud-cli
```

## Version Pinning and Downgrade

To install a specific version:

```bash
sudo apt-get install google-cloud-cli=VERSION_NUMBER-0
```

The apt repository keeps the ten most recent releases available. Versions before 371.0.0 used the package name `google-cloud-sdk` instead of `google-cloud-cli`.

## Notes

- **GPG key rotation.** Google occasionally rotates the signing key for their apt repository. If `apt-get update` starts failing with GPG errors, re-run the key import step (step 1) to fetch the new key.
- **No desktop required.** The `google-cloud-cli` apt package has no dependency on X11, Wayland, or any graphical libraries. It runs fine on a minimal server install.
- **The repository is architecture-aware.** It includes packages for amd64 and arm64 (and others). Apt will automatically select the right one for your machine.
- **Updates.** Since gcloud is installed via apt, updates come through the normal `sudo apt-get update && sudo apt-get upgrade` flow. You do not need to run `gcloud components update` (that command is disabled when installed via apt).
- **Configuration files.** gcloud stores its config in `~/.config/gcloud/`. This includes active account, project, and cached credentials. Back this up if needed, but do not commit it to source control.
- **Multiple configurations.** You can maintain separate named configurations (e.g., for different projects or accounts):
  ```bash
  gcloud config configurations create my-other-project
  gcloud config set project OTHER_PROJECT_ID
  gcloud config configurations activate default
  ```
