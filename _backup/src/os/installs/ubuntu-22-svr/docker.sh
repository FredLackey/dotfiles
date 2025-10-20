#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Docker\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Check if Docker is already installed
if package_is_installed "docker-ce"; then
    print_success "Docker is already installed"
    exit 0
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Install prerequisites
install_package "CA Certificates" "ca-certificates"
install_package "Curl" "curl"
install_package "Software Properties (Common)" "software-properties-common"
install_package "GNU Privacy Guard" "gnupg"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Remove old Docker packages
if package_is_installed "docker.io"; then
    execute \
    "sudo apt-get remove docker.io" \
    "Docker (remove docker.io)"
fi
if package_is_installed "docker-compose"; then
    execute \
    "sudo apt-get remove docker-compose" \
    "Docker (remove docker-compose)"
fi
if package_is_installed "containerd"; then
    execute \
    "sudo apt-get remove containerd" \
    "Docker (remove containerd)"
fi
if package_is_installed "runc"; then
    execute \
    "sudo apt-get remove runc" \
    "Docker (remove runc)"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add Docker's official GPG key (only if it doesn't exist)
if [ ! -f "/usr/share/keyrings/docker-archive-keyring.gpg" ]; then
    execute \
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg" \
      "Docker (add keys)"
else
    print_success "Docker GPG key already exists"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Detect architecture
ARCH=$(dpkg --print-architecture)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add Docker repository for Ubuntu (only if not already added)
if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
    execute \
      "echo \"deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" \
      "Docker (add repository)"
else
    print_success "Docker repository already exists"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Update package index
execute \
  "sudo apt update" \
  "Docker (update)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Install Docker Engine
install_package "Docker CE" "docker-ce"
install_package "Docker CE CLI" "docker-ce-cli"
install_package "Docker CE (containerd.io)" "containerd.io"
install_package "Docker CE (docker-buildx-plugin)" "docker-buildx-plugin"
install_package "Docker CE (docker-compose-plugin)" "docker-compose-plugin"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Add user to docker group
execute \
  "sudo usermod -aG docker $USER" \
  "Docker (update group)"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable Docker service
execute \
  "sudo systemctl enable docker" \
  "Docker (enable service)"

execute \
  "sudo systemctl start docker" \
  "Docker (start service)"

