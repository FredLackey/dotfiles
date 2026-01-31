# Ubuntu Server Shell Functions

This directory contains shell functions available in your terminal after dotfiles installation.

## Usage

Functions are automatically loaded when you open a new terminal session. They are sourced by `~/.bash_profile`.

## Available Functions

### Git & Repository Management

| Function | Description |
|----------|-------------|
| `clone` | Clone a repository and auto-install dependencies (npm/yarn) |
| `git-clone` | Copy repository files without .git folder using rsync |
| `git-pup` | Pull and update git submodules |
| `git-push` | Add, commit, and push with a message in one command |
| `git-backup` | Create a zip backup of a git repository |
| `set-git-public` | Set git user to Fred Lackey defaults |
| `fetch-github-repos` | Clone all repos from a GitHub organization |
| `vpush` | Commit and push using package.json version as message |

### Docker

| Function | Description |
|----------|-------------|
| `docker-clean` | Remove ALL Docker containers, images, and volumes |

### File Management

| Function | Description |
|----------|-------------|
| `delete-files` | Delete files matching a pattern (default: .DS_Store) |
| `org-by-date` | Organize files into date-based subdirectories |
| `rename-files-with-date-in-name` | Rename files to standardized date format |
| `resize-image` | Resize images using ImageMagick |
| `get-folder` | Copy files with rsync, skipping same-size duplicates |
| `refresh-files` | Refresh target files from source directory |
| `remove-smaller-files` | Remove smaller duplicate files between directories |
| `rm_safe` | Safe rm wrapper preventing root directory deletion |

### Media & Downloads

| Function | Description |
|----------|-------------|
| `get-tunes` | Download audio/video from YouTube using yt-dlp |
| `get-video` | Download video from URL using yt-dlp |
| `get-course` | Download Pluralsight courses using yt-dlp |
| `get-channel` | Download entire YouTube channel using yt-dlp |

### Development

| Function | Description |
|----------|-------------|
| `clean-dev` | Remove node_modules and bower_components directories |
| `npmi` | Reinstall npm dependencies with Node v18 |
| `killni` | Kill Node Inspector processes |
| `get-dependencies` | Extract dependency names from package.json |
| `install-dependencies-from` | Install dependencies from another package.json |
| `ncu-update-all` | Update all npm/bower dependencies in project |
| `datauri` | Convert a file to a data URI |
| `evm` | Execute Vim macro on files |

### System & Backup

| Function | Description |
|----------|-------------|
| `backup-source` | Backup ~/Source directory with rsync |
| `backup-all` | Full backup of user directories |
| `ips` | Scan local network for active IPs using nmap |

### Search & History

| Function | Description |
|----------|-------------|
| `h` | Search bash history with grep |
| `s` | Search current directory for text with grep |

### Utilities

| Function | Description |
|----------|-------------|
| `ccurl` | Curl a URL and pretty-print JSON with jq |
| `mkd` | Create directory and cd into it |

### Nginx & SSL

| Function | Description |
|----------|-------------|
| `nginx-init` | Create nginx proxy configuration |
| `certbot-init` | Install SSL certificates with Let's Encrypt |
| `certbot-crontab-init` | Add certbot auto-renewal cron job |

### AI Tools

| Function | Description |
|----------|-------------|
| `claude-danger` | Launch Claude CLI bypassing permission checks |

## Adding Custom Functions

1. Create a new file in `functions/bash/` named `your-function.sh`
2. Add the function definition following the existing patterns
3. Add a `source` line for your new file in `main.sh`
4. Restart your terminal or run `source ~/.bash_profile`
