#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Text-based Browsers (Server)\n\n"

# Install text-based browsers for server use
install_package "Lynx" "lynx"
install_package "Links" "links"
install_package "W3M" "w3m"
install_package "Curl" "curl"
