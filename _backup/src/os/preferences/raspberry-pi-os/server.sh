#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Server Configuration\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable SSH
execute \
    "sudo systemctl enable ssh" \
    "Enable SSH service"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set timezone
execute \
    "sudo timedatectl set-timezone UTC" \
    "Set timezone to UTC"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Configure log rotation
execute \
    "sudo sed -i 's/weekly/daily/' /etc/logrotate.conf" \
    "Set log rotation to daily"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Disable unnecessary services for server use
execute \
    "sudo systemctl disable bluetooth" \
    "Disable Bluetooth service"

execute \
    "sudo systemctl disable avahi-daemon" \
    "Disable Avahi service"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Configure Raspberry Pi specific settings
execute \
    "sudo raspi-config nonint do_ssh 0" \
    "Enable SSH via raspi-config"

execute \
    "sudo raspi-config nonint do_boot_behaviour B1" \
    "Set boot to console (no desktop)"

