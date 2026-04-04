# Podman - Ubuntu WSL Installation

## Tool Overview

| Field | Value |
|---|---|
| **Tool Name** | Podman |
| **Publisher** | Red Hat / Containers project |
| **Official Docs** | https://podman.io/docs/ |
| **Installation Docs** | https://podman.io/docs/installation |
| **GitHub** | https://github.com/containers/podman |
| **Ubuntu WSL Available** | Yes |

## Description

Podman is a daemonless, open-source container engine for developing, managing, and running OCI containers on Linux. It is the most common Docker alternative and is developed by Red Hat as part of the libpod library.

Key differences from Docker:

- **Daemonless** - No background daemon process required. Each Podman command runs as a standalone process, which makes it a natural fit for WSL where background services can be unreliable.
- **Rootless by default** - Containers run without root privileges out of the box, improving security.
- **Docker-compatible CLI** - Most `docker` commands work by replacing `docker` with `podman`. The command syntax is nearly identical.
- **No socket dependency** - Docker requires the Docker daemon socket (`/var/run/docker.sock`). Podman does not, which eliminates an entire class of permission and security issues.
- **Pod support** - Podman can group containers into pods (similar to Kubernetes pods), making it useful for local Kubernetes development.

## Prerequisites / Dependencies

- Ubuntu 20.10 or newer running under WSL 2 (Ubuntu 22.04 or 24.04 recommended)
- WSL 2 (not WSL 1 -- Podman requires a real Linux kernel)
- The following packages are pulled in automatically by apt but are worth knowing about:
  - `slirp4netns` - user-mode networking for rootless containers
  - `uidmap` - provides `newuidmap` and `newgidmap` for user namespace support
  - `fuse-overlayfs` - FUSE-based overlay filesystem for rootless storage

## Installation on Ubuntu WSL (apt method - recommended)

Podman is in the official Ubuntu repositories for 20.10+. No third-party repos are needed.

### Step 1: Update package lists

```bash
sudo apt-get update
```

### Step 2: Install Podman and rootless dependencies

```bash
sudo apt-get install -y podman slirp4netns uidmap fuse-overlayfs
```

The `slirp4netns`, `uidmap`, and `fuse-overlayfs` packages are typically pulled in as dependencies, but installing them explicitly ensures rootless mode works correctly.

### Step 3: Verify installation

```bash
podman --version
```

You should see output like `podman version 4.x.x` (or newer).

### Step 4: Run a test container

```bash
podman run --rm docker.io/library/hello-world
```

If this prints the "Hello from Docker!" message (yes, it says Docker -- the image is from Docker Hub), Podman is working correctly.

### Step 5: Check system info

```bash
podman info
```

This prints detailed information about the Podman configuration, storage driver, cgroup manager, and OS details. Review this output to confirm the storage and cgroup settings are correct (see WSL-specific notes below).

## WSL-Specific Configuration

### Systemd: Two paths depending on your WSL setup

Modern WSL 2 (version 0.67.6+, shipped with Windows 11 22H2 and later) supports systemd natively. If systemd is enabled, Podman works with its default settings. If systemd is not enabled, you need to adjust Podman's configuration.

**Check if systemd is running:**

```bash
ps -p 1 -o comm=
```

If the output is `systemd`, you are good. If it is `init` or anything else, systemd is not running.

**To enable systemd** (recommended if your WSL version supports it):

Edit `/etc/wsl.conf` inside your WSL distro:

```bash
sudo tee -a /etc/wsl.conf > /dev/null <<'EOF'
[boot]
systemd=true
EOF
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

Reopen your Ubuntu terminal and verify with `ps -p 1 -o comm=`.

**If you cannot or choose not to enable systemd**, configure Podman to avoid systemd-dependent features. Create or edit `~/.config/containers/containers.conf`:

```bash
mkdir -p ~/.config/containers

cat > ~/.config/containers/containers.conf <<'EOF'
[engine]
cgroup_manager = "cgroupfs"
events_logger = "file"

[engine.service_destinations]
EOF
```

This tells Podman to use cgroupfs instead of systemd for cgroup management and to log events to a file instead of journald.

### XDG_RUNTIME_DIR

Without systemd, the `XDG_RUNTIME_DIR` environment variable may not be set. Podman needs it. Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
  if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
  fi
fi
```

With systemd enabled, this variable is set automatically and you can skip this step.

### Mount propagation fix

WSL may not set `/` as a shared mount, which causes warnings or failures with rootless containers. If you see the warning `'/' is not a shared mount`, run:

```bash
sudo mount --make-rshared /
```

To make this persist across WSL restarts, add the command to `/etc/wsl.conf`:

```bash
sudo tee -a /etc/wsl.conf > /dev/null <<'EOF'
[boot]
command = "mount --make-rshared /"
EOF
```

Note: If you already have a `[boot]` section with `systemd=true`, just add the `command` line under it. Do not duplicate the `[boot]` header.

### Container image registry configuration

By default Podman may not resolve short image names (like `alpine` instead of `docker.io/library/alpine`). Create a registries config to set Docker Hub as the default:

```bash
mkdir -p ~/.config/containers

cat > ~/.config/containers/registries.conf <<'EOF'
[registries.search]
registries = ['docker.io']
EOF
```

This allows you to run `podman pull alpine` without specifying the full registry path.

## Docker Compatibility

### Using podman as a Docker drop-in replacement

Podman's CLI is designed to be compatible with Docker's. You have several options:

**Option 1: Shell alias (simplest)**

```bash
alias docker=podman
```

Add to `~/.bashrc` or `~/.zshrc` to make it permanent.

**Option 2: Symlink (works with scripts and other tools)**

```bash
mkdir -p ~/.local/bin
ln -sf "$(which podman)" ~/.local/bin/docker
```

Ensure `~/.local/bin` is on your PATH before `/usr/bin`.

**Option 3: Install the podman-docker package (system-wide)**

```bash
sudo apt-get install -y podman-docker
```

This package installs a `docker` command that redirects to Podman and also provides a Docker-compatible socket. This is the most thorough compatibility option and works with tools that expect a real `docker` binary.

### Docker Compose support

Podman supports Docker Compose through `podman-compose` (a Python-based tool) or natively through a compatibility socket that allows the official `docker-compose` to talk to Podman:

```bash
# Option A: Install podman-compose
sudo apt-get install -y podman-compose

# Option B: Enable the Podman socket for docker-compose compatibility
systemctl --user enable --now podman.socket
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
```

Option B requires systemd to be enabled. Option A works without systemd.

### Known compatibility gaps

- Some Docker-specific flags or behaviors may not be 1:1 identical. Most standard workflows work fine, but edge cases exist.
- Docker Swarm is not supported. Podman uses pods instead.
- BuildKit-specific features in `docker build` may not all be available. Podman uses Buildah as its build backend.
- `podman stats` requires cgroups v2 in rootless mode. If you see errors, check that your WSL kernel supports cgroups v2.

## Updating

Podman is updated through the standard apt workflow:

```bash
sudo apt-get update
sudo apt-get install --only-upgrade podman
```

## Uninstalling

```bash
sudo apt-get remove --purge podman
rm -rf ~/.config/containers ~/.local/share/containers
```

## Sources

- [Podman Installation Instructions](https://podman.io/docs/installation)
- [Guide 2 WSL: Podman](https://www.guide2wsl.com/podman/)
- [Using Podman on WSL 2 (DEV Community)](https://dev.to/bowmanjd/using-podman-on-windows-subsystem-for-linux-wsl-58ji)
- [How to Install Podman on WSL2 Ubuntu (Medium)](https://medium.com/@vikrantdheer/fixing-podman-install-on-wsl2-ubuntu-55ae86382521)
- [Install Podman on Windows with WSL2 (OneUptime)](https://oneuptime.com/blog/post/2026-03-16-install-podman-windows-wsl2/view)
- [Podman cgroupv2 systemd issue (GitHub #17202)](https://github.com/containers/podman/issues/17202)
- [WSL systemd rootless Podman issue (GitHub WSL #13053)](https://github.com/microsoft/WSL/issues/13053)
- [Podman Docker Compatibility (Podman Desktop docs)](https://podman-desktop.io/docs/migrating-from-docker/managing-docker-compatibility)
