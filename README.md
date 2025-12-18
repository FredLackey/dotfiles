# Dotfiles

Automated setup for macOS and Ubuntu development environments. Installs tools, configures shell, Git, Vim, and tmux with sensible defaults.

## Supported Platforms

- macOS (Apple Silicon and Intel)
- Ubuntu 20/22/23/24 (Server and Workstation)
- Raspberry Pi OS

## What It Does

- Installs development tools and applications via Homebrew (macOS) or APT (Ubuntu)
- Configures Bash with aliases, functions, and a customized prompt
- Sets up Git with aliases, colors, and GPG commit signing
- Configures Vim and tmux
- Installs and configures [gitego](https://github.com/bgreenwell/gitego) for managing multiple Git identities
- Creates `*.local` files for machine-specific customizations

## Installation

Run the appropriate command for your OS:

**macOS:**
```bash
bash -c "$(curl -LsS https://raw.github.com/fredlackey/dotfiles/main/src/os/setup.sh)"
```

**Ubuntu:**
```bash
bash -c "$(wget -qO - https://raw.github.com/fredlackey/dotfiles/main/src/os/setup.sh)"
```

The setup will prompt for a destination directory (default: `~/projects/dotfiles`).

For non-interactive installation (CI/CD):
```bash
./src/os/setup.sh -y
```

## Post-Installation

After installation, configure your Git identity in `~/.gitconfig.local`:

```
[user]
    name = Your Name
    email = your@email.com
    signingkey = YOUR_GPG_KEY_ID
```

## Customization

Machine-specific settings go in `*.local` files (never committed):

| File | Purpose |
|------|---------|
| `~/.bash.local` | Custom aliases, PATH additions, environment variables |
| `~/.gitconfig.local` | Git user identity and signing key |
| `~/.vimrc.local` | Vim customizations |

These files are automatically sourced/included after the main configuration files.

## Updating

Re-run the setup script from your dotfiles directory:

```bash
cd ~/projects/dotfiles/src/os && ./setup.sh
```

## Directory Structure

```
src/
  shell/      # Bash configuration (aliases, functions, exports, prompt)
  git/        # Git configuration
  vim/        # Vim configuration and plugins
  tmux/       # tmux configuration
  bin/        # Custom scripts
  os/         # Setup scripts and OS-specific installers
```

## License

[MIT](LICENSE.txt)
