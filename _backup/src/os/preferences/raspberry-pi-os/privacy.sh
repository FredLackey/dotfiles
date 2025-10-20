#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Privacy\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Disable Bluetooth if not needed (for headless server)
execute \
    "sudo systemctl disable bluetooth" \
    "Disable Bluetooth"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Disable WiFi power management for better connectivity
execute \
    "echo 'options 8192cu rtw_power_mgnt=0 rtw_enusbss=0' | sudo tee /etc/modprobe.d/8192cu.conf" \
    "Disable WiFi power management"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Disable unnecessary services for headless server
execute \
    "sudo systemctl disable avahi-daemon" \
    "Disable Avahi service"
