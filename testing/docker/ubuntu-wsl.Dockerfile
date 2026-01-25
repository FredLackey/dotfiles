# Ubuntu WSL Test Environment
# Simulates Windows Subsystem for Linux (as closely as Docker allows)

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install minimal dependencies that would exist in a fresh WSL install
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

# Simulate WSL's /proc/version marker
# In real WSL, /proc/version contains "Microsoft" or "WSL"
# We can't modify /proc in Docker, so we set the environment variable instead
# The setup.sh script checks both /proc/version AND $WSL_DISTRO_NAME

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Set WSL environment variable
# This is one of the markers setup.sh uses to detect WSL
ENV WSL_DISTRO_NAME=Ubuntu

# Note: We cannot perfectly simulate WSL in Docker because:
# 1. /proc/version is read-only and shows Linux, not Microsoft
# 2. Windows filesystem interop doesn't exist
# However, the WSL_DISTRO_NAME variable should trigger WSL detection in setup.sh

# Default command shows environment info
CMD ["bash", "-c", "echo '=== Ubuntu WSL Test Environment ===' && echo 'User:' $(whoami) && echo 'Home:' $HOME && echo 'WSL_DISTRO_NAME:' $WSL_DISTRO_NAME && bash"]
