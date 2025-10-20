#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Vim\n\n"

# Install Vim
install_package "Vim" "vim"

# Install additional Vim packages for better functionality
install_package "Vim Common" "vim-common"
install_package "Vim Runtime" "vim-runtime"

# Install Vim plugins dependencies
install_package "Git" "git"
install_package "Curl" "curl"
