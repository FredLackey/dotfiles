#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   tmux\n\n"

# Install tmux
install_package "tmux" "tmux"

# Install tmux plugins dependencies
install_package "Xclip" "xclip"
