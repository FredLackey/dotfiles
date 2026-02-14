#!/bin/bash
# ~/.bash_profile - Bash configuration for login shells
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# ------------------------------------------------------------------------------
# Dotfiles Functions
# ------------------------------------------------------------------------------

if [[ -f ~/.dotfiles/src/os/ubuntu-server/functions/bash/main.sh ]]; then
    source ~/.dotfiles/src/os/ubuntu-server/functions/bash/main.sh
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
# Betamax (Terminal Recorder)
# ------------------------------------------------------------------------------

if [[ -d "$HOME/code/betamax" ]]; then
    export PATH="$HOME/code/betamax:$PATH"
fi

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
if [[ -f ~/.dotfiles/src/os/ubuntu-server/files/bash_colors.sh ]]; then
    source ~/.dotfiles/src/os/ubuntu-server/files/bash_colors.sh
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
# Prompt
# ------------------------------------------------------------------------------

# Git repository details for prompt
get_git_repository_details() {
    local branchName=""
    local tmp=""

    # Check if the current directory is in a Git repository
    ! git rev-parse &>/dev/null && return

    # Check if in .git/ directory
    [ "$(git rev-parse --is-inside-git-dir)" == "true" ] && return

    # Check for uncommitted changes in the index
    if ! git diff --quiet --ignore-submodules --cached; then
        tmp="$tmp+"
    fi

    # Check for unstaged changes
    if ! git diff-files --quiet --ignore-submodules --; then
        tmp="$tmp!"
    fi

    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        tmp="$tmp?"
    fi

    # Check for stashed files
    if git rev-parse --verify refs/stash &>/dev/null; then
        tmp="$tmp$"
    fi

    [ -n "$tmp" ] && tmp=" [$tmp]"

    branchName="$( printf "%s" "$( git rev-parse --abbrev-ref HEAD 2> /dev/null \
        || git rev-parse --short HEAD 2> /dev/null \
        || printf " (unknown)" )" | tr -d "\n" )"

    printf "%s" "$1$branchName$tmp"
}

# Set up prompt
set_prompts() {
    local bold=$(tput bold 2> /dev/null)
    local reset=$(tput sgr0 2> /dev/null)

    local cyan=""
    local green=""
    local orange=""
    local white=""
    local yellow=""

    if [ "$(tput colors 2> /dev/null || printf "0")" -ge 256 ]; then
        # Solarized colors
        cyan=$(tput setaf 37)
        green=$(tput setaf 64)
        orange=$(tput setaf 166)
        white=$(tput setaf 15)
        yellow=$(tput setaf 136)
    fi

    PS1="\[\033]0;\W\007\]"  # Terminal title
    PS1+="$reset$bold"
    PS1+="$orange\u"          # Username
    PS1+="$white@"
    PS1+="$yellow\h"          # Host
    PS1+="$white: "
    PS1+="$green\w"           # Working directory
    PS1+="\$(get_git_repository_details \"$white on $cyan\")"
    PS1+="\n"
    PS1+="\[$reset\]\[$white\]$ \[$reset\]"

    export PS1

    PS2=">>> "
    export PS2

    PS4="+$( tput cr 2> /dev/null; tput cuf 6 2> /dev/null; printf "%s" "$reset" )"
    export PS4
}

set_prompts
unset -f set_prompts

# ------------------------------------------------------------------------------
# Local Configuration
# ------------------------------------------------------------------------------

# Source local customizations if present
if [[ -f ~/.bash.local ]]; then
    source ~/.bash.local
fi
