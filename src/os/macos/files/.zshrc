# ~/.zshrc - Zsh configuration for interactive shells
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# ------------------------------------------------------------------------------
# Dotfiles Functions
# ------------------------------------------------------------------------------

if [[ -f ~/.dotfiles/src/os/macos/functions/zsh/main.sh ]]; then
    source ~/.dotfiles/src/os/macos/functions/zsh/main.sh
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
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS      # Don't record duplicate entries
setopt HIST_IGNORE_SPACE     # Don't record entries starting with space
setopt SHARE_HISTORY         # Share history between sessions

# Directory navigation
setopt AUTO_CD               # cd by typing directory name
setopt AUTO_PUSHD            # Push directories onto stack
setopt PUSHD_IGNORE_DUPS     # Don't push duplicates

# Completion
autoload -Uz compinit && compinit
setopt COMPLETE_IN_WORD      # Complete from cursor position
setopt ALWAYS_TO_END         # Move cursor to end after completion

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

eval "$(starship init zsh)"

# ------------------------------------------------------------------------------
# Custom Configuration
# ------------------------------------------------------------------------------

# Add your custom configuration below this line
