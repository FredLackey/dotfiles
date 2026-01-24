# Shell Cosmetics - Previous Dotfiles Implementation

Research findings from `/Users/flackey/projects/dotfiles/src/shell/` documenting how terminal appearance consistency was achieved across macOS and Linux.

## File Structure

```
src/shell/
├── bash_profile          # Entry point, sources all config files
├── bashrc                # Dispatcher that sources bash_profile (if interactive)
├── bash_init             # OS-specific initialization
├── bash_prompt           # Prompt styling (PS1, PS2, PS4)
├── bash_colors           # Color definitions + OS-specific loader
├── bash_exports          # Environment variables (including LESS_TERMCAP)
├── bash_options          # Bash shell options
├── bash_aliases          # Command aliases
├── bash_functions        # Utility functions (1700+ lines)
├── bash_autocompletion   # Command completion
├── inputrc               # Readline/terminal input configuration
├── macos/
│   └── bash_colors       # LSCOLORS for BSD ls
├── ubuntu-24-svr/
│   ├── bash_colors       # LS_COLORS for GNU ls
│   └── bash_init         # Ubuntu-specific init
└── raspberry-pi-os/
    └── bash_colors       # LS_COLORS for Raspberry Pi
```

## Cross-Platform Strategy

Each common file (e.g., `bash_colors`) sources an OS-specific override at the end:

```bash
. "$OS/bash_colors"  # Sources macos/bash_colors or ubuntu-24-svr/bash_colors
```

OS detection happens at runtime via a `get_os_name()` utility that returns identifiers like `macos`, `ubuntu-24-svr`, `ubuntu-24-wks`, or `raspberry-pi-os`.

## Color Systems by Platform

### macOS (BSD) - LSCOLORS

BSD `ls` uses the `LSCOLORS` variable with `-G` flag. It consists of 11 pairs of characters (foreground + background) for different file types:

```bash
LSCOLORS=""
LSCOLORS+="gx"  # Directory (cyan, default bg)
LSCOLORS+="fx"  # Symbolic link (magenta, default bg)
LSCOLORS+="cx"  # Socket (yellow, default bg)
LSCOLORS+="dx"  # Pipe (blue, default bg)
LSCOLORS+="cx"  # Executable (yellow, default bg)
# ... 10 pairs total

alias ls="ls -G"
```

### Linux (GNU) - LS_COLORS

GNU `ls` uses the `LS_COLORS` variable with `--color=auto`. Colon-separated key=value pairs using ANSI escape codes:

```bash
LS_COLORS=""
LS_COLORS+="no=0;39:"   # Global default
LS_COLORS+="di=0;36:"   # Directory (cyan)
LS_COLORS+="ex=0;32:"   # Executable (green)
LS_COLORS+="fi=0;39:"   # File (default)
LS_COLORS+="ln=target:"  # Symbolic link (color of target)
LS_COLORS+="or=31;01"   # Broken symlink (red, bold)

if [ -x /usr/bin/dircolors ]; then
    if test -r ~/.dircolors; then
        eval "$(dircolors -b ~/.dircolors)"
    fi
    alias ls="ls --color=auto"
    alias grep="grep --color=auto"
fi
```

## Terminal Capability Detection

```bash
enable_color_support() {
    if [[ $COLORTERM == gnome-* && $TERM == xterm ]] \
        && infocmp gnome-256color &> /dev/null; then
        export TERM="gnome-256color"
    elif infocmp xterm-256color &> /dev/null; then
        export TERM="xterm-256color"
    fi

    . "$OS/bash_colors"
}
```

Uses `infocmp` to detect capabilities and upgrades `TERM` to 256-color when available.

## Prompt Configuration (PS1)

Uses `tput` for terminal-independent color control with Solarized theme colors:

```bash
set_prompts() {
    local bold=$(tput bold 2> /dev/null)
    local reset=$(tput sgr0 2> /dev/null)

    # 256-color Solarized palette (with fallback)
    if [ "$(tput colors 2> /dev/null || printf "0")" -ge 256 ]; then
        cyan=$(tput setaf 37)
        green=$(tput setaf 64)
        orange=$(tput setaf 166)
        white=$(tput setaf 15)
        yellow=$(tput setaf 136)
    fi

    PS1="\[\033]0;\W\007\]"          # Terminal title
    PS1+="$reset$bold"
    PS1+="$orange\u"                  # Username
    PS1+="$white@"
    PS1+="$yellow\h"                  # Hostname
    PS1+="$white: "
    PS1+="$green\w"                   # Working directory
    PS1+="\$(get_git_repository_details \"$white on $cyan\")"
    PS1+="\n"
    PS1+="\[$reset\]\[$white\]$ \[$reset\]"

    PS2="⚡ "  # Continuation prompt
}
```

**Result:** `username@hostname: /working/directory on main [+!?$]`

## Git Status in Prompt

The `get_git_repository_details()` function appends branch name and status indicators:

| Symbol | Meaning |
|--------|---------|
| `+` | Staged changes |
| `!` | Unstaged changes |
| `?` | Untracked files |
| `$` | Stashed files |

## Man Page Colors

```bash
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"
export MANPAGER="less -X"
```

## Readline Configuration (inputrc)

- VI editing mode
- Case-insensitive tab completion
- Tab cycles through options (menu-complete)
- Up/down arrows search history by prefix
- Bell disabled

## Design Principles

1. **tput over raw escape codes** - Terminal-independent color control
2. **Graceful degradation** - Falls back when 256-color unavailable
3. **OS abstraction** - Common files with OS-specific overrides
4. **Runtime detection** - No hardcoded platform assumptions
5. **Solarized theme** - Consistent palette across all platforms
6. **Consistent aliases** - Platform-appropriate flags (`-G` vs `--color=auto`) producing same visual result
