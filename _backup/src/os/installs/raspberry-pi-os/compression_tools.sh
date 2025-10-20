#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Compression Tools\n\n"

# Install common compression tools
install_package "ZIP" "zip"
install_package "Unzip" "unzip"
install_package "Gzip" "gzip"
install_package "Bzip2" "bzip2"
install_package "XZ Utils" "xz-utils"
install_package "7-Zip" "p7zip-full"
install_package "LZMA" "lzma"
