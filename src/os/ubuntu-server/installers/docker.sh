#!/bin/bash
set -e

APP_NAME="Docker"

# 1. Check if already installed
if command -v docker >/dev/null 2>&1 && dpkg -l | grep -q "^ii  docker-ce "; then
    echo "$APP_NAME is already installed."
    exit 0
fi

# 2. Install prerequisites
echo "Installing $APP_NAME prerequisites..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ca-certificates curl software-properties-common gnupg

# 3. Remove old Docker packages if present
for pkg in docker.io docker-compose containerd runc; do
    if dpkg -l | grep -q "^ii  $pkg "; then
        echo "Removing old package: $pkg"
        sudo apt-get remove -y -qq "$pkg"
    fi
done

# 4. Add Docker's official GPG key
if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    echo "Adding Docker GPG key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
fi

# 5. Add Docker repository
ARCH=$(dpkg --print-architecture)
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "Adding Docker repository..."
    echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
fi

# 6. Install Docker Engine
echo "Installing $APP_NAME..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 7. Add user to docker group
echo "Adding user to docker group..."
sudo usermod -aG docker "$USER"

# 8. Enable and start Docker service
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# 9. Verify
if command -v docker >/dev/null 2>&1; then
    echo "$APP_NAME installed successfully."
    echo "Note: Log out and back in for docker group membership to take effect."
else
    echo "Error: $APP_NAME installation failed."
    exit 1
fi
