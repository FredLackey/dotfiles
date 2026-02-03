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
# Terminal Color Support
# ------------------------------------------------------------------------------

# Upgrade TERM to 256-color when available
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] \
    && infocmp gnome-256color &> /dev/null; then
    export TERM="gnome-256color"
elif infocmp xterm-256color &> /dev/null; then
    export TERM="xterm-256color"
fi

# Source platform-specific color configuration (LSCOLORS)
if [[ -f ~/.dotfiles/src/os/macos/files/bash_colors.sh ]]; then
    source ~/.dotfiles/src/os/macos/files/bash_colors.sh
fi

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------

# History settings
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth      # Ignore duplicates and entries starting with space
HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
shopt -s histappend         # Append to history, don't overwrite

# Directory navigation
shopt -s cdspell            # Correct minor spelling errors in cd

# Globbing
shopt -s nocaseglob         # Case-insensitive globbing
shopt -s dotglob            # Include dotfiles in globbing
shopt -s extglob            # Extended pattern matching

# Terminal behavior
shopt -s checkwinsize       # Update LINES/COLUMNS after each command
shopt -s cmdhist            # Save multi-line commands in one history entry
shopt -s no_empty_cmd_completion  # No PATH search on empty line completion

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# Default editor
export EDITOR="vim"

# Prefer US English and use UTF-8 encoding
export LANG="en_US"
export LC_ALL="en_US.UTF-8"

# Colored man pages
export LESS_TERMCAP_md="$(tput bold 2> /dev/null; tput setaf 2 2> /dev/null)"
export LESS_TERMCAP_me="$(tput sgr0 2> /dev/null)"

# Don't clear the screen after quitting a man page
export MANPAGER="less -X"

# Make Python use UTF-8 encoding for output
export PYTHONIOENCODING="UTF-8"

# Silence macOS bash deprecation warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# Sync history across sessions
if ! printf "%s" "$PROMPT_COMMAND" | grep "history -a" &> /dev/null; then
    export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
fi

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# File operations (verbose + interactive)
alias cp="cp -iv"
alias mv="mv -iv"
alias mkdir="mkdir -pv"

# Listing
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Quick commands
alias c="clear"
alias q="exit"
alias e="vim --"
alias m="man"
alias path='printf "%b\n" "${PATH//:/\\n}"'

# ------------------------------------------------------------------------------
# Prompt (Starship)
# ------------------------------------------------------------------------------

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# ------------------------------------------------------------------------------
# Custom Configuration
# ------------------------------------------------------------------------------

# Add your custom configuration below this line
