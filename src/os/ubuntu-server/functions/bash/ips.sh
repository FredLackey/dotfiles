#!/bin/bash
# Scan the local network for active IPs using nmap.
#
# Usage:
#   ips                 # Scan 192.168.1.0/24 with sudo
#   ips 10.0.0.0 16     # Scan 10.0.0.0/16 with sudo
#   ips ip-only         # Scan default network, show only IPs
#   ips no-sudo         # Scan default network without sudo

ips() {
    local usage="ips [%NETWORK_BASE_IP%] [%BIT_DEPTH%] [ip-only | no-sudo]"$'\n'"Default IP: 192.168.1.0"$'\n'"Default Mask: 24"
    local addr="$1"
    local mask="$2"
    local prefix=""
    local suffix=""

    # Ensure nmap is installed
    if ! command -v nmap &>/dev/null; then
        printf "nmap is required, please install it!\n"
        return 1
    fi

    # Display help if needed
    if [[ "$*" =~ "help" ]]; then
        echo "$usage"
        return 0
    fi

    # Filter out details if only IPs are needed
    if [[ "$*" =~ "ip-only" ]]; then
        suffix=" | grep report | awk '{print \$5}'"
    fi

    # Remove sudo if is to be run without it
    if [[ "$*" =~ "no-sudo" ]]; then
        prefix=""
    else
        prefix="sudo "
    fi

    # Ensure the subnet mask is between 4 and 32 bits (default to 24)
    if [[ "$mask" =~ ^[0-9]+$ ]] && [ "$mask" -ge 4 ] && [ "$mask" -le 30 ]; then
        mask="$mask"
    else
        mask="24"
    fi

    # Proceed if the first value is a valid IP address
    if [[ ! "$addr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        addr="192.168.1.0"
    fi

    eval "${prefix}nmap $addr/$mask -n -sP${suffix}"
}
