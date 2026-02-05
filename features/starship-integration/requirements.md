# Starship Integration - Requirements

## Goal

Integrate [Starship](https://starship.rs/) as the cross-shell prompt for all supported environments (macOS, Ubuntu Desktop/Server/WSL, Windows). Starship will be the sole prompt customization layer — **no Oh My Zsh or Oh My Bash** will be used at this stage (and possibly never).

## Supported Shells

- **Zsh** (macOS default, Linux)
- **Bash** (Linux, macOS fallback)
- **PowerShell** (Windows)

## Developer Focus

The configuration should be optimized for a software developer working primarily with:

- MEAN Stack (MongoDB, Express, Angular, Node.js)
- MERN Stack (MongoDB, Express, React, Node.js)
- Next.js / React
- Node.js / npm / yarn / pnpm
- TypeScript / JavaScript
- Git (heavy usage)
- Docker

## Starship Modules to Enable

| Module | Purpose |
|--------|---------|
| `[nodejs]` | Display Node.js version (triggers on `package.json`, `.nvmrc`, `.node-version`, JS/TS files) |
| `[package]` | Display package version from `package.json` |
| `[git_branch]` | Display current Git branch |
| `[git_status]` | Display staged/modified/untracked file counts |
| `[git_commit]` | Display commit hash in detached HEAD state |
| `[docker_context]` | Display Docker context (triggers on `Dockerfile`, `docker-compose.yml`) |
| `[directory]` | Display current working directory |
| `[cmd_duration]` | Display execution time for long-running commands |
| `[character]` | Success/error indicator for last command |

## Font Requirements

### Primary Font: MesloLGM Nerd Font Mono

- Widely recommended for terminal use, great readability
- Popular default for Oh My Zsh and Powerlevel10k
- Based on Apple's Menlo font with customizable line gap variants (S/M/L)
- Includes 3,600+ patched glyphs (Devicons, Font Awesome, Octicons, Material Design Icons)
- Homebrew cask: `font-meslo-lg-nerd-font`

### Secondary Font: FiraCode Nerd Font

- Best ligature support for JS/TS operators (`===`, `!==`, `=>`, `<=`, `>=`)
- Most widely documented and tested with Starship
- Homebrew cask: `font-fira-code-nerd-font`

### Tertiary Font: JetBrains Mono Nerd Font

- Excellent character differentiation (`0` vs `O`, `1` vs `l`, `I` vs `l`)
- Designed by JetBrains specifically for source code readability
- Homebrew cask: `font-jetbrains-mono-nerd-font`

### Key Glyphs Used (from Nerd Font Devicons)

| Technology | Glyph | Unicode |
|-----------|-------|---------|
| Node.js | `nf-dev-nodejs` | U+E719 |
| npm | `nf-dev-npm` | U+E71E |
| Git | `nf-dev-git` | U+F1D3 |
| Docker | `nf-dev-docker` | U+E7B0 |
| React | `nf-dev-react` | U+E7BA |
| TypeScript | `nf-dev-typescript` | U+E8CA |
| JavaScript | `nf-dev-javascript` | U+E781 |
| MongoDB | `nf-dev-mongodb` | U+E7A4 |
| Package | `nf-md-package` | U+F0C4E |

## Starship Preset

Use the **Nerd Font Symbols** preset as a baseline:

```
starship preset nerd-font-symbols -o ~/.config/starship.toml
```

This replaces emoji-based symbols with Nerd Font glyphs for a cleaner, more consistent appearance.

## Platform-Specific Considerations

### macOS

- **Do NOT rely on Terminal.app** — it has poor Nerd Font glyph rendering
- Target iTerm2 or Alacritty for best results
- Install fonts via Homebrew: `brew install font-meslo-lg-nerd-font`

### Windows / WSL

- Fonts must be installed on the **host Windows system**, not inside WSL
- Windows Terminal supports Nerd Fonts natively (configure in `settings.json` under `profiles.defaults.font.face`)
- The `git_status` module can be slow on Windows filesystem paths (`/mnt/c/`); consider performance tuning for WSL

### Linux (Ubuntu Desktop/Server)

- Install fonts to `~/.local/share/fonts/` and run `fc-cache -fv`
- GNOME Terminal may not show Nerd Fonts in the font picker (they lack the monospace flag); use `dconf` to set the font directly if needed
- Alacritty/Kitty have no font rendering issues

## Terminal Color Requirements

- Terminals should support **true color (24-bit)** for optimal theme rendering
- At minimum, 256-color support is required
- Named colors (`red`, `green`, `bold blue`) provide maximum compatibility as a fallback

## Configuration Location

- Starship config: `~/.config/starship.toml`
- Shell init lines:
  - Zsh: `eval "$(starship init zsh)"` in `~/.zshrc`
  - Bash: `eval "$(starship init bash)"` in `~/.bashrc`
  - PowerShell: `Invoke-Expression (&starship init powershell)` in `$PROFILE`

## Non-Goals

- No Oh My Zsh
- No Oh My Bash
- No Oh My Posh
- No Powerlevel10k
- No shell-specific prompt frameworks — Starship handles everything
