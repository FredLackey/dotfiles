#!/bin/bash
# ~/.bash_profile - Bash configuration for login shells
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# ------------------------------------------------------------------------------
# Dotfiles Functions
# ------------------------------------------------------------------------------

if [[ -f ~/.dotfiles/src/os/ubuntu-wsl/functions/bash/main.sh ]]; then
    source ~/.dotfiles/src/os/ubuntu-wsl/functions/bash/main.sh
fi

# ------------------------------------------------------------------------------
# NVM (Node Version Manager)
# ------------------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ------------------------------------------------------------------------------
# Local Binaries
# ------------------------------------------------------------------------------

if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ------------------------------------------------------------------------------
# Go Language
# ------------------------------------------------------------------------------

export PATH="$HOME/go/bin:$PATH"


# ------------------------------------------------------------------------------
# TFEnv (Terraform Version Manager)
# ------------------------------------------------------------------------------

export PATH="$HOME/.tfenv/bin:$PATH"

# ------------------------------------------------------------------------------
# GPG Configuration
# ------------------------------------------------------------------------------

export GPG_TTY=$(tty)

# ------------------------------------------------------------------------------
# Terminal Color Support
# ------------------------------------------------------------------------------

if [[ $COLORTERM == gnome-* && $TERM == xterm ]] \
    && infocmp gnome-256color &> /dev/null; then
    export TERM="gnome-256color"
elif infocmp xterm-256color &> /dev/null; then
    export TERM="xterm-256color"
fi

# Source platform-specific color configuration
if [[ -f ~/.dotfiles/src/os/ubuntu-wsl/files/bash_colors.sh ]]; then
    source ~/.dotfiles/src/os/ubuntu-wsl/files/bash_colors.sh
fi

# ------------------------------------------------------------------------------
# Bash Completion
# ------------------------------------------------------------------------------

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# ------------------------------------------------------------------------------
# Shell Options
# ------------------------------------------------------------------------------

# Vi editing mode
set -o vi

# History settings
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth      # Ignore duplicates and entries starting with space
HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
shopt -s histappend         # Append to history, don't overwrite

# Directory navigation
shopt -s autocd             # Auto cd to directories by typing directory name
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
# Environment Variables
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

# Node REPL history size
export NODE_REPL_HISTORY_SIZE=10000

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
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'

# Quick commands
alias c="clear"
alias q="exit"
alias e="vim --"
alias m="man"
alias path='printf "%b\n" "${PATH//:/\\n}"'
alias cc="claude-danger"
alias co="codex-danger"

# APT shortcuts
alias apti="sudo apt-get install"
alias aptr="sudo apt-get remove"
alias apts="sudo apt-cache search"
alias aptu="sudo apt-get update && sudo apt-get upgrade"
alias u="sudo apt-get update && sudo apt-get upgrade"

# Empty trash
alias empty-trash="rm -rf ~/.local/share/Trash/files/*"

# Network
alias local-ip='hostname -I | awk '\''{print $1}'\'''
alias myip='curl -s https://ipinfo.io/ip'

# Find all package.json files
alias packages="find ./ -type f -name \"package.json\" -not -path \"*/node_modules/*\" | sort"

# ------------------------------------------------------------------------------
# Starship Prompt
# ------------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# ------------------------------------------------------------------------------
# Local Configuration
# ------------------------------------------------------------------------------

# Source local customizations if present
if [[ -f ~/.bash.local ]]; then
    source ~/.bash.local
fi
