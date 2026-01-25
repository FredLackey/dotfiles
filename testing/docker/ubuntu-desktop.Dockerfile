# Ubuntu Desktop Test Environment
# Simulates Ubuntu desktop (CLI portions only - no actual GUI)

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies that would exist on a real Ubuntu desktop
# curl and unzip are required by setup.sh
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root test user (simulates real user on fresh install)
# Grant passwordless sudo
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Set XDG_CURRENT_DESKTOP to simulate desktop environment
# This is how setup.sh detects "desktop" vs "server"
ENV XDG_CURRENT_DESKTOP=GNOME

# Default command shows environment info
CMD ["bash", "-c", "echo '=== Ubuntu Desktop Test Environment ===' && echo 'User:' $(whoami) && echo 'Home:' $HOME && echo 'XDG_CURRENT_DESKTOP:' $XDG_CURRENT_DESKTOP && bash"]
