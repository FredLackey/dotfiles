#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Go\n\n"

install_package "Go" "golang-go"

# Pinentry for GPG signing in terminal (complements gnupg installed by docker.sh)
install_package "Pinentry TTY" "pinentry-tty"
