# Podman - Ubuntu Server Installation

## Tool Overview

**Podman** is a daemonless, open-source container engine developed by Red Hat for running OCI-compliant containers on Linux. Unlike Docker, Podman does not require a background daemon process -- it runs containers directly as child processes of the calling user. This makes it a strong fit for headless servers where you want to avoid the security and resource overhead of a persistent root daemon.

Podman is a drop-in replacement for most Docker CLI commands. If you know Docker, you already know most of Podman.

- **Official docs:** <https://podman.io/>
- **GitHub:** <https://github.com/containers/podman>
- **Available for Ubuntu Server:** Yes. The `podman` package is in the official Ubuntu repositories for Ubuntu 20.10 and newer.

## Key Differences from Docker

- **No daemon.** Podman runs containers as direct child processes. No `dockerd` or `containerd` sitting in the background.
- **Rootless by default.** Podman can run containers without root privileges, which is a significant security advantage on shared or production servers.
- **Pod-native.** Podman supports Kubernetes-style pods natively (groups of containers sharing a network namespace).
- **Systemd integration.** Podman can generate systemd unit files for containers, making it easy to manage containers as system services.

## Prerequisites

- **Ubuntu 20.10 or newer** (Ubuntu 22.04 LTS, 24.04 LTS, or newer recommended)
- **sudo access** for initial installation
- **uidmap** package (provides `newuidmap` and `newgidmap` for rootless mode -- installed as a dependency)
- **passt** package (provides `pasta`, the default rootless networking tool since Podman 5.0)

## Installation Steps

### 1. Update the package index

```bash
sudo apt-get update
```

### 2. Install Podman

```bash
sudo apt-get install -y podman
```

That's it. The package manager pulls in all required dependencies (`uidmap`, `crun` or `runc`, `conmon`, `containers-common`, `netavark` or `containernetworking-plugins`, etc.).

### 3. Verify the installation

```bash
podman --version
```

You should see output like: `podman version 4.9.3` (version varies by Ubuntu release).

### 4. Run a quick smoke test

```bash
podman run --rm docker.io/library/hello-world
```

If this prints the "Hello from Docker!" message and exits cleanly, Podman is working.

## Getting a Newer Version (Optional)

The version of Podman in Ubuntu's default repos can lag behind upstream. If you need Podman 5.x on an LTS release like 24.04, you have a couple of options:

### Option A: Ubuntu's official unstable PPA

```bash
sudo add-apt-repository -y ppa:projectatomic/ppa
sudo apt-get update
sudo apt-get install -y podman
```

### Option B: Build from source

This is documented at <https://podman.io/docs/installation#building-from-source> but is generally not recommended for production servers. Stick with the packaged version unless you have a specific feature requirement.

## Post-Install Configuration

### Configure container registries

By default, Podman on Ubuntu may not have Docker Hub configured as a search registry. When you pull an image without a full registry prefix (e.g., `podman pull nginx` instead of `podman pull docker.io/library/nginx`), Podman needs to know where to look.

Create a registry configuration drop-in:

```bash
sudo tee /etc/containers/registries.conf.d/shortnames.conf << 'EOF'
unqualified-search-registries = ["docker.io"]
EOF
```

After this, `podman pull nginx` resolves to `docker.io/library/nginx` without prompting.

### Rootless mode setup

Podman runs rootless out of the box for any non-root user, but verify the prerequisites are in place:

**Check subuid/subgid mappings:**

```bash
grep "$(whoami)" /etc/subuid
grep "$(whoami)" /etc/subgid
```

You should see a line like `youruser:100000:65536` in each file. If your user is missing, add it:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $(whoami)
```

After modifying subuid/subgid, apply the changes to any running Podman processes:

```bash
podman system migrate
```

**Check that a rootless networking tool is installed:**

```bash
# For Podman 5.0+ (pasta is the default)
which pasta || sudo apt-get install -y passt

# For older Podman (slirp4netns was the default)
which slirp4netns || sudo apt-get install -y slirp4netns
```

**Verify rootless mode works:**

```bash
podman run --rm docker.io/library/alpine cat /etc/os-release
```

Run this as your normal (non-root) user. If it completes without errors, rootless Podman is working.

### User-level configuration files (optional)

Podman reads per-user configuration from `~/.config/containers/`. These files override the system defaults in `/etc/containers/`:

- **`~/.config/containers/containers.conf`** -- General container runtime settings
- **`~/.config/containers/storage.conf`** -- Where images and container data are stored (defaults to `~/.local/share/containers/storage`)
- **`~/.config/containers/registries.conf`** -- Per-user registry overrides

You only need to create these if you want to customize behavior. The system defaults are fine for most use cases.

### Enable lingering for rootless containers that run at boot

If you want rootless containers to start automatically at boot (before the user logs in), enable systemd lingering:

```bash
sudo loginctl enable-linger $(whoami)
```

Then generate a systemd user service for your container:

```bash
podman generate systemd --new --name my-container > ~/.config/systemd/user/my-container.service
systemctl --user enable my-container.service
systemctl --user start my-container.service
```

## Docker Compatibility

### CLI compatibility

Most Docker CLI commands work with Podman by simply replacing `docker` with `podman`. For convenience, you can alias it:

```bash
echo 'alias docker=podman' >> ~/.bashrc
source ~/.bashrc
```

Or install the `podman-docker` package, which creates a system-wide symlink and provides a Docker-compatible socket:

```bash
sudo apt-get install -y podman-docker
```

This creates `/usr/bin/docker` as a symlink to `podman` and sets up a socket that tools expecting the Docker API can use.

### Docker Compose compatibility

Podman 4.7+ includes a built-in `podman compose` subcommand that acts as a thin wrapper around either `docker-compose` or `podman-compose`:

```bash
# Install podman-compose via pip
pip3 install podman-compose

# Or install docker-compose (the reference Compose implementation)
sudo apt-get install -y docker-compose
```

Then use it:

```bash
podman compose up -d
podman compose down
```

If both `docker-compose` and `podman-compose` are installed, `podman compose` prefers `docker-compose` since it is the reference implementation and more feature-complete.

### Known differences

- Podman does not support Docker Swarm. If you need orchestration, use Kubernetes or Podman's native pod support.
- Some Docker-specific API extensions may not be available. The vast majority of day-to-day container operations work identically.
- Volume mount behavior and networking defaults can differ slightly. Test your Docker Compose files before assuming they work without changes.

## Notes

- **cgroup v2 is recommended.** Ubuntu 21.10+ uses cgroup v2 by default. If you are on an older release with cgroup v1, rootless Podman still works but with some limitations. You can check with: `stat -fc %T /sys/fs/cgroup/` (should print `cgroup2fs`).
- **No daemon means no restart policy like Docker.** Instead of `--restart=always`, use systemd services (see "Enable lingering" above) to manage container lifecycle on a server.
- **Image storage is per-user in rootless mode.** Images pulled by your normal user are stored in `~/.local/share/containers/storage`, not in a shared system location. Images pulled with `sudo podman pull` are separate from rootless images.
- **Podman Desktop exists but is irrelevant here.** Podman Desktop is a GUI application for macOS and Windows. On a headless Ubuntu Server, you only need the `podman` CLI package.
