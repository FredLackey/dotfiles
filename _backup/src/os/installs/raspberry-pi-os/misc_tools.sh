#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Server Development Tools\n\n"

# Install development tools
install_package "Make" "make"
install_package "CMake" "cmake"
install_package "GCC" "gcc"
install_package "G++" "g++"

# Install network and server tools
install_package "Net-tools" "net-tools"
# install_package "SSH Server" "openssh-server"
# install_package "UFW Firewall" "ufw"
# install_package "Fail2Ban" "fail2ban"

# Install web server tools
# install_package "Nginx" "nginx"
# install_package "Apache2" "apache2"
# install_package "Certbot" "certbot"

# Install database tools
install_package "PostgreSQL Client" "postgresql-client"
