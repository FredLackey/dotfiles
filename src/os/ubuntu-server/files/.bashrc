#!/bin/bash
# ~/.bashrc - Bash configuration for interactive shells
# Installed by dotfiles: https://github.com/FredLackey/dotfiles

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source bash_profile for login shell settings
[ -f "$HOME/.bash_profile" ] && . "$HOME/.bash_profile"
