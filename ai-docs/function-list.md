# Bash Functions Inventory

**Source:** `/Users/flackey/projects/dotfiles/src/shell/bash_functions`
**Discovered:** 2026-01-18

This document catalogs all custom bash functions from the existing local dotfiles installation. Each entry includes the function name, purpose, usage, and any external dependencies that must be installed.

---

## Table of Contents

1. [Dependencies Summary](#dependencies-summary)
2. [Docker Functions](#docker-functions)
3. [Git Functions](#git-functions)
4. [File Management Functions](#file-management-functions)
5. [Media Download Functions](#media-download-functions)
6. [Node.js/NPM Functions](#nodejsnpm-functions)
7. [Backup Functions](#backup-functions)
8. [Network Functions](#network-functions)
9. [Nginx/SSL Functions](#nginxssl-functions)
10. [Utility Functions](#utility-functions)

---

## Dependencies Summary

### Quick Install (macOS with Homebrew)

```bash
# Core utilities
brew install jq git nmap imagemagick

# Media downloads
brew install yt-dlp

# Docker (or install Docker Desktop)
brew install docker
```

### Server-Only Dependencies (Not Installed on macOS)

The following dependencies are for server environments only (Ubuntu Server, WSL) and are **not installed** on macOS workstations:

| Dependency | Used By Functions | Notes |
|------------|-------------------|-------|
| `nginx` | nginx-init, certbot-init | Web server - Linux servers only |
| `certbot` | certbot-init | SSL certificates - Linux servers only |
| `openssh-server` | N/A | SSH server - Linux servers only (macOS uses built-in SSH client) |

### All External Dependencies

| Dependency | Install Command | Used By Functions |
|------------|-----------------|-------------------|
| `jq` | `brew install jq` | vpush, get-dependencies, install-dependencies-from, ccurl, fetch-github-repos |
| `git` | `brew install git` | clone, vpush, set-git-public, git-clone, git-pup, git-push, git-backup, fetch-github-repos |
| `docker` | Docker Desktop or `brew install docker` | dp, docker-clean |
| `yt-dlp` | `brew install yt-dlp` | get-course, get-channel, get-tunes, get-video |
| `nmap` | `brew install nmap` | ips |
| `imagemagick` | `brew install imagemagick` | resize-image |
| `nvm` | [See nvm repo](https://github.com/nvm-sh/nvm) | npmi |
| `ncu` | `npm install -g npm-check-updates` | ncu-update-all |
| `yarn` | `npm install -g yarn` | clone (optional) |
| `claude` | `npm install -g @anthropic-ai/claude-code` | claude-danger |

### Pre-installed on macOS (no action needed)

| Dependency | Used By Functions |
|------------|-------------------|
| `rsync` | backup-source, backup-all, git-clone, get-folder |
| `curl` | ccurl, fetch-github-repos |
| `openssl` | datauri |
| `file` | datauri |
| `vim` | evm |
| `grep` | h, s |
| `less` | h, s |
| `zip` | git-backup |

### Linux-Only Dependencies

| Dependency | Install Command | Used By Functions | Notes |
|------------|-----------------|-------------------|-------|
| `xsel` | `apt install xsel` | talk | Clipboard access |
| `festival` | `apt install festival` | talk | Text-to-speech engine |

### External Files Required

| File | Required By | Location (relative to bash_functions) |
|------|-------------|---------------------------------------|
| `nginx-docker-host.conf` | nginx-init | `../../templates/` |
| `nginx-docker-host-api.conf` | nginx-init (with --api flag) | `../../templates/` |

---

## Docker Functions

### `dp`
**Purpose:** Display Docker containers in a formatted table showing ID, names, and ports.

**Usage:**
```bash
dp
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| docker | CLI tool | `brew install docker` or Docker Desktop |

---

### `docker-clean`
**Purpose:** Remove ALL Docker containers, images, and volumes. Includes confirmation prompt to prevent accidental data loss.

**Usage:**
```bash
docker-clean
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| docker | CLI tool | `brew install docker` or Docker Desktop |

---

## Git Functions

### `clone`
**Purpose:** Clone a repository and automatically install dependencies (npm or yarn) if `package.json` exists.

**Usage:**
```bash
clone https://github.com/user/repo.git
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |
| npm | CLI tool | Included with Node.js |
| yarn | CLI tool (optional) | `npm install -g yarn` |

---

### `vpush`
**Purpose:** Commit and push a Node project using the package version from `package.json` as the commit message.

**Usage:**
```bash
vpush
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |
| jq | CLI tool | `brew install jq` |

---

### `set-git-public`
**Purpose:** Set git user email and name to public defaults (fred.lackey@gmail.com / Fred Lackey).

**Usage:**
```bash
set-git-public
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |

---

### `git-clone`
**Purpose:** Copy a repository structure without the `.git` folder using rsync (useful for templating).

**Usage:**
```bash
git-clone /path/to/source/repo/
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| rsync | CLI tool | Pre-installed on macOS |

---

### `git-pup`
**Purpose:** Pull changes and update git submodules in one command.

**Usage:**
```bash
git-pup
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |

---

### `git-push`
**Purpose:** Add all changes, commit with a message, and push to the current branch in one command.

**Usage:**
```bash
git-push "Fix bug #123"
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |

---

### `git-backup`
**Purpose:** Create a timestamped zip backup of a git repository (mirror clone) with a README explaining restoration.

**Usage:**
```bash
git-backup /path/to/backups/                    # Backup current repo
git-backup /path/to/backups/ git@github.com:user/repo.git  # Backup remote repo
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |
| zip | CLI tool | Pre-installed on macOS |

---

### `fetch-github-repos`
**Purpose:** Clone all repositories from a GitHub organization into a specified directory.

**Usage:**
```bash
fetch-github-repos my-org ./cloned-repos
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| git | CLI tool | `brew install git` |
| jq | CLI tool | `brew install jq` |
| curl | CLI tool | Pre-installed on macOS |

---

## File Management Functions

### `mkd`
**Purpose:** Create a new directory and immediately cd into it.

**Usage:**
```bash
mkd my-project
```

**Dependencies:** None (uses built-in commands)

---

### `datauri`
**Purpose:** Create a base64 data URI from a file (useful for embedding images in CSS/HTML).

**Usage:**
```bash
datauri image.png
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| file | CLI tool | Pre-installed on macOS |
| openssl | CLI tool | Pre-installed on macOS |

---

### `delete-files`
**Purpose:** Delete files matching a pattern from the current directory. Defaults to `.DS_Store` files.

**Usage:**
```bash
delete-files "*.log"  # Delete all .log files
delete-files          # Delete all .DS_Store files (default)
```

**Dependencies:** None (uses built-in `find`)

---

### `rename-files-with-date-in-name`
**Purpose:** Rename files containing dates in the filename to a standardized format: `YYYY-MM-DD HH.MM.SS.ext`

**Usage:**
```bash
rename-files-with-date-in-name path/to/directory
rename-files-with-date-in-name path/to/file.jpg
```

**Supports formats like:**
- `20200505_050505.dng` → `2020-05-05 05.05.05.dng`
- `Screenshot 2020-01-02 at 03.04.05.png` → `2020-01-02 03.04.05.png`
- `signal-2020-05-06-07-08-09-123.mp4` → `2020-05-06 07.08.09.mp4`

**Dependencies:** None (uses built-in `sed` and `find`)

---

### `resize-image`
**Purpose:** Resize an image using high-quality resampling (Sinc/Jinc windowed filter).

**Usage:**
```bash
resize-image ./path/to/image.jpg 30%
resize-image ./path/to/image.jpg 1000x1000!
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| ImageMagick | CLI tool | `brew install imagemagick` |

---

### `org-by-date`
**Purpose:** Organize files in the current directory into subdirectories based on dates found in filenames (YYYY/MM/DD structure).

**Usage:**
```bash
org-by-date
```

**Dependencies:** None (uses built-in commands)

---

### `get-folder`
**Purpose:** Copy files from source to target directory, skipping files that already exist with the same size.

**Usage:**
```bash
get-folder /path/to/source/ /path/to/target/
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| rsync | CLI tool | Pre-installed on macOS |
| robocopy | CLI tool (Windows) | Built into Windows |

---

### `refresh-files`
**Purpose:** Refresh files in a target directory from a source directory, only overwriting files that exist in both locations. Useful for protecting critical vendor files.

**Usage:**
```bash
refresh-files /path/to/source/            # Target defaults to current directory
refresh-files /path/to/source/ /path/to/target/
```

**Dependencies:** None (uses built-in `find` and `cp`)

---

### `remove_smaller_files`
**Purpose:** Compare files in current directory with another directory and remove the smaller version of each duplicate pair.

**Usage:**
```bash
remove_smaller_files /path/to/other/directory
```

**Dependencies:** None (uses built-in commands)

---

### `rm_safe`
**Purpose:** A safer wrapper around `rm` that prevents accidental removal of root or top-level directories. Blocks `/`, `/some_dir`, `/*`, and `--no-preserve-root`.

**Usage:**
```bash
rm_safe file.txt directory/
rm_safe -rf old_files/
```

**Note:** The bash_aliases file sets `alias rm='rm_safe'` to make this the default behavior.

**Dependencies:** None (wraps built-in `rm`)

---

## Media Download Functions

### `get-course`
**Purpose:** Download a Pluralsight course using yt-dlp with rate limiting and sleep intervals.

**Usage:**
```bash
get-course course-name-from-url username password
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| yt-dlp | CLI tool | `brew install yt-dlp` |

---

### `get-channel`
**Purpose:** Download all videos from a YouTube channel.

**Usage:**
```bash
get-channel channelName
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| yt-dlp | CLI tool | `brew install yt-dlp` |

---

### `get-tunes`
**Purpose:** Download audio and/or video from a URL (YouTube, etc.) with options for audio-only or video-only.

**Usage:**
```bash
get-tunes https://www.youtube.com/watch?v=video_id            # Both audio & video
get-tunes https://www.youtube.com/watch?v=video_id audio-only # Audio only (MP3)
get-tunes https://www.youtube.com/watch?v=video_id video-only # Video only (MP4)
get-tunes https://www.youtube.com/playlist?list=playlist_id   # Full playlist
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| yt-dlp | CLI tool | `brew install yt-dlp` |

---

### `get-video`
**Purpose:** Download video from a URL in MP4 format.

**Usage:**
```bash
get-video https://www.youtube.com/watch?v=video_id
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| yt-dlp | CLI tool | `brew install yt-dlp` |

---

## Node.js/NPM Functions

### `clean-dev`
**Purpose:** Remove `node_modules` and `bower_components` directories recursively from the current directory tree.

**Usage:**
```bash
clean-dev
```

**Dependencies:** None (uses built-in `find`)

---

### `npmi`
**Purpose:** Reinstall npm dependencies after removing `node_modules` and switching to Node v18 via nvm.

**Usage:**
```bash
npmi
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| npm | CLI tool | Included with Node.js |
| nvm | Version manager | See [nvm repo](https://github.com/nvm-sh/nvm) |

---

### `get-dependencies`
**Purpose:** Extract dependency names from a `package.json` file by type (dependencies, devDependencies, peerDependencies, etc.).

**Usage:**
```bash
get-dependencies ./package.json          # Get 'dependencies'
get-dependencies ./package.json dev      # Get 'devDependencies'
get-dependencies ./package.json peer     # Get 'peerDependencies'
get-dependencies ./package.json opt      # Get 'optionalDependencies'
get-dependencies ./package.json bundle   # Get 'bundledDependencies'
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| jq | CLI tool | `brew install jq` |

---

### `install-dependencies-from`
**Purpose:** Install dependencies listed in a specified `package.json` file into the current project.

**Usage:**
```bash
install-dependencies-from ../source/package.json        # Install 'dependencies'
install-dependencies-from ../source/package.json dev    # Install as devDependencies
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| npm | CLI tool | Included with Node.js |
| jq | CLI tool | `brew install jq` |

---

### `ncu-update-all`
**Purpose:** Update all npm and bower dependencies across a project using npm-check-updates.

**Usage:**
```bash
ncu-update-all
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| ncu | CLI tool | `npm install -g npm-check-updates` |

---

### `killni`
**Purpose:** Kill Node Inspector processes (`node --debug-brk`).

**Usage:**
```bash
killni
```

**Dependencies:** None (uses built-in commands)

---

## Backup Functions

### `backup-source`
**Purpose:** Back up the `~/Source` directory using rsync with extensive exclusions for dev artifacts.

**Usage:**
```bash
backup-source /path/to/backups/
```

**Excludes:** `.Trash`, `.android`, `.atom`, `.bash_sessions`, `.cache`, `.cups`, `.dropbox`, `.git`, `.next`, `.npm`, `.nvm`, `.viminfo`, `bower_components`, `node_modules`, `.tmp`, `.idea`, `.DS_Store`, `.terraform`

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| rsync | CLI tool | Pre-installed on macOS |

---

### `backup-all`
**Purpose:** Back up multiple user directories (`Downloads`, `Desktop`, `Documents`, `Movies`, `Music`, `Pictures`, `Source`, etc.) using rsync.

**Usage:**
```bash
backup-all /path/to/backups/
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| rsync | CLI tool | Pre-installed on macOS |

---

## Network Functions

### `ips`
**Purpose:** Scan the local network for active IP addresses using nmap.

**Usage:**
```bash
ips                            # Scan 192.168.1.0/24 with sudo
ips 10.0.0.0 16               # Scan 10.0.0.0/16 with sudo
ips ip-only                   # Show only IP addresses
ips no-sudo                   # Scan without sudo
ips 192.168.1.0 24 ip-only no-sudo  # Combine options
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| nmap | CLI tool | `brew install nmap` |

---

## Nginx/SSL Functions

### `nginx-init`
**Purpose:** Initialize nginx configuration from template files for proxying to Docker containers or local services.

**Usage:**
```bash
nginx-init -d example.com -h http://127.0.0.1:3000 -f example.conf
nginx-init -d example.com -d www.example.com -h http://127.0.0.1:3000 -f example.conf
nginx-init --api -d api.example.com -h http://127.0.0.1:8080 -f api.conf --link
```

**Options:**
- `-a, --api` - Use API template instead of standard template
- `-d, --domain` - Domain name (can be used multiple times)
- `-h, --host` - Upstream URL for proxy_pass
- `-f, --file` - Output filename (must end with .conf)
- `-l, --link` - Create symbolic link in sites-enabled

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| nginx | Web server | `brew install nginx` or `apt install nginx` |
| sudo | Privilege escalation | Pre-installed |

**External Files Required:**
- `../../templates/nginx-docker-host.conf` (relative to bash_functions)
- `../../templates/nginx-docker-host-api.conf` (relative to bash_functions)

---

### `certbot-init`
**Purpose:** Install SSL certificates using certbot for nginx. Will automatically install certbot if not present.

**Usage:**
```bash
certbot-init -d example.com -e admin@example.com
certbot-init -d example.com -d www.example.com -e admin@example.com
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| certbot | CLI tool | Auto-installed by function |
| nginx | Web server | `brew install nginx` or `apt install nginx` |
| sudo | Privilege escalation | Pre-installed |

---

### `certbot-crontab-init`
**Purpose:** Add certbot renewal cron job if it doesn't already exist. Will start and enable cron service if needed.

**Usage:**
```bash
certbot-crontab-init
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| cron/crond | System service | Pre-installed |
| systemctl | System manager | Pre-installed on Linux |

---

## Utility Functions

### `evm`
**Purpose:** Execute a Vim macro (stored in register 'q') on specified files.

**Usage:**
```bash
evm file.txt               # Run macro 'q' once on file.txt
evm file1.txt file2.txt 3  # Run macro 'q' 3 times on both files
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| vim | Text editor | `brew install vim` |

---

### `h`
**Purpose:** Search command history using grep with colored output and paging.

**Usage:**
```bash
h "git commit"
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| grep | CLI tool | Pre-installed on macOS |
| less | Pager | Pre-installed on macOS |

---

### `s`
**Purpose:** Search for text within the current directory recursively, excluding `.git` and `node_modules`.

**Usage:**
```bash
s "my_variable"
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| grep | CLI tool | Pre-installed on macOS |
| less | Pager | Pre-installed on macOS |

---

### `talk`
**Purpose:** Convert selected text to speech using festival text-to-speech.

**Usage:**
```bash
# Select text first, then run:
talk
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| xsel | Clipboard tool | `apt install xsel` (Linux only) |
| festival | TTS engine | `apt install festival` (Linux only) |

**Note:** This function is Linux-specific and won't work on macOS.

---

### `ccurl`
**Purpose:** Curl a URL expecting JSON response and pretty-print the output using jq.

**Usage:**
```bash
ccurl https://api.example.com/data
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| curl | CLI tool | Pre-installed on macOS |
| jq | CLI tool | `brew install jq` |

---

### `claude-danger`
**Purpose:** Launch Claude CLI with dangerous mode, bypassing permission checks.

**Usage:**
```bash
claude-danger
claude-danger "some prompt"
```

**Dependencies:**
| Dependency | Type | Install Command |
|------------|------|-----------------|
| claude | CLI tool | `npm install -g @anthropic/claude-code` |

---

## Dependencies Summary

### Required for Core Functions
| Tool | Used By | Install Command |
|------|---------|-----------------|
| `jq` | vpush, get-dependencies, install-dependencies-from, ccurl, fetch-github-repos | `brew install jq` |
| `git` | clone, vpush, set-git-public, git-clone, git-pup, git-push, git-backup, fetch-github-repos | `brew install git` |
| `rsync` | backup-source, backup-all, git-clone, get-folder | Pre-installed on macOS |

### Required for Media Downloads
| Tool | Used By | Install Command |
|------|---------|-----------------|
| `yt-dlp` | get-course, get-channel, get-tunes, get-video | `brew install yt-dlp` |

### Required for Docker Functions
| Tool | Used By | Install Command |
|------|---------|-----------------|
| `docker` | dp, docker-clean | Docker Desktop or `brew install docker` |

### Required for Network/Server Functions
| Tool | Used By | Install Command |
|------|---------|-----------------|
| `nmap` | ips | `brew install nmap` |
| `nginx` | nginx-init, certbot-init | `brew install nginx` |
| `certbot` | certbot-init | Auto-installed by function |

### Required for Image Processing
| Tool | Used By | Install Command |
|------|---------|-----------------|
| ImageMagick (`convert`) | resize-image | `brew install imagemagick` |

### Required for Node.js Development
| Tool | Used By | Install Command |
|------|---------|-----------------|
| `npm` | clone, npmi, install-dependencies-from | Included with Node.js |
| `nvm` | npmi | See [nvm repo](https://github.com/nvm-sh/nvm) |
| `ncu` | ncu-update-all | `npm install -g npm-check-updates` |
| `yarn` | clone (optional) | `npm install -g yarn` |

### Linux-Only Tools
| Tool | Used By | Notes |
|------|---------|-------|
| `xsel` | talk | Clipboard access on Linux |
| `festival` | talk | Text-to-speech on Linux |

---

## Aliases Reference

The following aliases are defined in `bash_aliases` and `macos/bash_aliases`:

### Navigation
- `..` → `cd ..`
- `...` → `cd ../..`
- `....` → `cd ../../..`
- `d` → `cd ~/Desktop`
- `p` → `cd ~/projects`

### File Operations
- `cp` → `cp -iv` (interactive, verbose)
- `mv` → `mv -iv` (interactive, verbose)
- `rm` → `rm_safe` (safe wrapper)
- `mkdir` → `mkdir -pv` (create parents, verbose)

### Shortcuts
- `c` → `clear`
- `e` → `vim --`
- `ll` → `ls -l`
- `m` → `man`
- `n` → `npm`
- `o` → `open` (macOS)
- `q` / `:q` → `exit`
- `t` → `tmux`
- `y` → `yarn`

### Networking
- `ip` → Show external IP via OpenDNS
- `local-ip` → `ipconfig getifaddr en1` (macOS)
- `ports` → `lsof -i -P -n`

### macOS Specific
- `afk` → Lock screen
- `brewd/brewi/brewr/brews/brewu` → Homebrew shortcuts
- `clear-dns-cache` → Flush DNS cache
- `empty-trash` → Empty trash and clear system logs
- `hide-desktop-icons` / `show-desktop-icons` → Toggle desktop icons
- `hide-hidden-files` / `show-hidden-files` → Toggle hidden files in Finder
- `u` → Update system and Homebrew

### Terraform
- `tpo` → `terraform plan -out="tfplan"`
- `tpa` → `terraform apply "tfplan"`

### Utilities
- `count-files` → Count files in current directory
- `count-folders` → Count folders in current directory
- `count` → Show both file and folder counts
- `iso` → ISO timestamp in LA timezone
- `path` → Display PATH entries on separate lines
- `map` → `xargs -n1`
- `code-all` → Open all subdirectories in VS Code
- `packages` → Find all package.json files with timestamps
