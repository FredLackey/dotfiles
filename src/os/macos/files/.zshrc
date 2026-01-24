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
# Aliases
# ------------------------------------------------------------------------------

alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# ------------------------------------------------------------------------------
# Prompt
# ------------------------------------------------------------------------------

# Simple prompt with directory and git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '

# ------------------------------------------------------------------------------
# Custom Configuration
# ------------------------------------------------------------------------------

# Add your custom configuration below this line
