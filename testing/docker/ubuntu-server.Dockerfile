# Ubuntu Server Test Environment
# Simulates a fresh Ubuntu server with minimal packages

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies that would exist on a real Ubuntu server
# curl and unzip are required by setup.sh
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root test user (simulates real user on fresh install)
# Grant passwordless sudo (common in VM/cloud setups)
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Ensure no desktop environment variables are set
# This is how setup.sh detects "server" vs "desktop"
ENV XDG_CURRENT_DESKTOP=""

# Default command shows environment info
CMD ["bash", "-c", "echo '=== Ubuntu Server Test Environment ===' && echo 'User:' $(whoami) && echo 'Home:' $HOME && echo 'Shell:' $SHELL && bash"]
