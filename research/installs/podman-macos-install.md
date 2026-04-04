# Podman - macOS Installation

## What Is Podman?

Podman (Pod Manager) is a daemonless, open-source container engine developed by Red Hat. It can build, run, and manage OCI containers and container images without requiring a background daemon process, unlike Docker. Podman's CLI is intentionally Docker-compatible, so most `docker` commands work by simply replacing `docker` with `podman`.

**License:** Apache-2.0 AND GPL-3.0-or-later

## Official Documentation

- Homepage: <https://podman.io>
- Installation docs: <https://podman.io/docs/installation>
- Podman Machine docs: <https://docs.podman.io/en/latest/markdown/podman-machine-init.1.html>
- Homebrew formula: <https://formulae.brew.sh/formula/podman>

## macOS Availability

Yes. Podman fully supports macOS (both Apple Silicon and Intel). Requires macOS 13 (Ventura) or later.

Because containers depend on the Linux kernel, Podman on macOS runs a lightweight Linux virtual machine behind the scenes via `podman machine`. This is transparent to the user after initial setup.

## Prerequisites / Dependencies

- macOS 13 or later
- Homebrew (for the Homebrew installation method)
- No other runtime dependencies needed; Homebrew handles everything

Build-time dependencies (handled automatically by Homebrew):
- Go
- go-md2man
- Make

## Installation

### Option 1: Homebrew (simplest)

Homebrew is the most common installation method, though the Podman project notes that direct downloads from podman.io offer a more stable experience since Homebrew builds are community-maintained.

```bash
# 1. Install Podman
brew install podman

# 2. Initialize the Linux VM (downloads a Fedora CoreOS image)
podman machine init

# 3. Start the VM
podman machine start

# 4. Verify
podman info
```

### Option 2: Official Installer (.dmg)

Download the `.dmg` installer from the [Podman releases page](https://github.com/containers/podman/releases) or from [podman.io](https://podman.io). This bundles Podman, the CLI, and all required components together, so it tends to be more stable than the Homebrew route.

After installing via the `.dmg`, open a terminal and run:

```bash
podman machine init
podman machine start
podman info
```

### Option 3: Podman Desktop (GUI)

Podman Desktop is a graphical application that bundles the Podman engine and provides a Docker Desktop-like experience.

```bash
brew install --cask podman-desktop
```

The setup wizard handles machine initialization automatically on first launch.

## Verification

```bash
# Check the installed version
podman --version

# Show detailed engine and machine info
podman info

# Run a quick test container
podman run --rm hello-world

# Check machine status
podman machine list
```

## Post-Install Configuration

### Podman Machine Customization

The default machine works fine for most use cases. To customize resources:

```bash
# Create a machine with specific resources
podman machine init --cpus 4 --memory 4096 --disk-size 50

# Or to start it immediately after init
podman machine init --now --cpus 4 --memory 4096
```

Default machine name is `podman-machine-default`. Machine config is stored under `$XDG_CONFIG_HOME/containers/podman/machine/`.

### Rootful vs Rootless

By default, Podman runs in rootless mode. If you need privileged container operations:

```bash
podman machine init --rootful
```

### Auto-Start the Machine

The machine does not auto-start on login by default. You need to run `podman machine start` each time, or set it up as a launch agent if you want it to start automatically.

## Docker Compatibility

Podman is designed as a drop-in replacement for Docker. Most workflows migrate with zero changes.

### Shell Alias

The simplest approach. Add to `~/.zshrc`:

```bash
alias docker=podman
```

### Docker Compose

Podman supports Docker Compose natively (v2+). With the alias or socket in place, `docker compose` commands work as expected.

### Docker API Socket

Podman exposes a Docker-compatible API socket so tools that talk to the Docker daemon (SDKs, CI tools, etc.) work without modification. On macOS, set the `DOCKER_HOST` environment variable to point at Podman's socket:

```bash
export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')"
```

### Known Differences from Docker

- Volume mounts on macOS go through the VM, so paths must be accessible to the machine. The default machine mounts your home directory.
- Some edge-case Docker CLI flags or behaviors may differ. See the [known incompatibilities discussion](https://github.com/containers/podman/discussions/14430) for details.
- Podman does not use a persistent daemon. Each `podman` CLI invocation is a standalone process.

## Uninstallation

```bash
# Stop and remove the machine first
podman machine stop
podman machine rm

# Then uninstall
brew uninstall podman
```

## Sources

- [Podman Official Installation Docs](https://podman.io/docs/installation)
- [Podman Homebrew Formula](https://formulae.brew.sh/formula/podman)
- [Podman Machine Init Docs](https://docs.podman.io/en/latest/markdown/podman-machine-init.1.html)
- [Podman Desktop macOS Install](https://podman-desktop.io/docs/installation/macos-install)
- [Managing Docker Compatibility - Podman Desktop](https://podman-desktop.io/docs/migrating-from-docker/managing-docker-compatibility)
- [Red Hat: How to Run Containers on Mac with Podman](https://www.redhat.com/en/blog/run-containers-mac-podman)
