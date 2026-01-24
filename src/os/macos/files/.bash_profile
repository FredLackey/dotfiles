# ~/.bash_profile - Bash configuration for login shells
# Installed by dotfiles: https://github.com/FredLackey/dotfiles
#
# Note: macOS Terminal.app opens login shells, so this file is sourced
# instead of .bashrc. We source .bashrc from here for consistency.

# ------------------------------------------------------------------------------
# Source .bashrc if it exists
# ------------------------------------------------------------------------------

if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# ------------------------------------------------------------------------------
# Dotfiles Functions
# ------------------------------------------------------------------------------

if [[ -f ~/.dotfiles/src/os/macos/functions/bash/main.sh ]]; then
    source ~/.dotfiles/src/os/macos/functions/bash/main.sh
fi

# ------------------------------------------------------------------------------
# Path Configuration
# ------------------------------------------------------------------------------

# Homebrew (Apple Silicon)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew (Intel)
if [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ------------------------------------------------------------------------------
# NVM (Node Version Manager)
# ------------------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"

# Load NVM (Homebrew installation)
if [[ -s "$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh" ]]; then
    source "$(brew --prefix)/opt/nvm/nvm.sh"
    [[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ]] && source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
# Load NVM (Standard installation)
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ------------------------------------------------------------------------------
# Bash Completion
# ------------------------------------------------------------------------------

# Homebrew bash-completion
if command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix)"
    # bash-completion@2 (for bash 4+)
    if [[ -r "${BREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
        source "${BREW_PREFIX}/etc/profile.d/bash_completion.sh"
    # bash-completion (legacy, for bash 3.x)
    elif [[ -r "${BREW_PREFIX}/etc/bash_completion" ]]; then
        source "${BREW_PREFIX}/etc/bash_completion"
    fi
fi

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth      # Ignore duplicates and entries starting with space
shopt -s histappend         # Append to history, don't overwrite

# Directory navigation
shopt -s cdspell            # Correct minor spelling errors in cd

# Globbing
shopt -s nocaseglob            # Case-insensitive globbing

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------

alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# ------------------------------------------------------------------------------
# Prompt (Starship)
# ------------------------------------------------------------------------------

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# ------------------------------------------------------------------------------
# Custom Configuration
# ------------------------------------------------------------------------------

# Add your custom configuration below this line
