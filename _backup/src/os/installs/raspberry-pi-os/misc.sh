#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Server Tools\n\n"

# Install useful command-line tools for server use
install_package "Curl" "curl"
install_package "Wget" "wget"
install_package "Tree" "tree"
install_package "Htop" "htop"
install_package "Neofetch" "neofetch"
install_package "Vim" "vim"
install_package "Nano" "nano"
install_package "Screen" "screen"
install_package "JQ" "jq"

# Install server monitoring tools
install_package "IOTop" "iotop"
install_package "Iftop" "iftop"
install_package "Nethogs" "nethogs"
install_package "Nload" "nload"

# Install Raspberry Pi specific tools
install_package "Raspberry Pi Config" "raspi-config"
