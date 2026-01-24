#!/bin/bash
# ips - Scan local network for active IP addresses using nmap
#
# Usage:
#   ips                            # Scan 192.168.1.0/24 with sudo
#   ips 10.0.0.0 16               # Scan 10.0.0.0/16 with sudo
#   ips ip-only                   # Show only IP addresses
#   ips no-sudo                   # Scan without sudo
#   ips 192.168.1.0 24 ip-only no-sudo  # Combine options
#   ips help                      # Show usage
#
# Dependencies:
#   - nmap (brew install nmap)

ips() {
    local usage="ips [IP_ADDRESS] [BIT_DEPTH] [ip-only] [no-sudo]"$'\n'"Default IP: 192.168.1.0"$'\n'"Default Mask: 24"
    local addr="$1"
    local mask="$2"
    local prefix=""
    local suffix=""

    # Check if nmap is installed
    if ! command -v nmap &> /dev/null; then
        echo "Error: nmap is required but not installed."
        echo "Install with: brew install nmap"
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

    # Remove sudo if requested
    if [[ "$*" =~ "no-sudo" ]]; then
        prefix=""
    else
        prefix="sudo "
    fi

    # Ensure the subnet mask is between 4 and 32 bits (default to 24)
    if [[ "$mask" =~ ^[0-9]+$ ]] && [ "$mask" -ge 4 ] && [ "$mask" -le 30 ]; then
        mask="$mask"
    else
        if [[ -n "$mask" ]] && [[ ! "$mask" =~ ^(ip-only|no-sudo|help)$ ]]; then
            echo "Invalid mask supplied. Defaulting to 24 bits."
        fi
        mask="24"
    fi

    # Proceed if the first value is a valid IP address
    if [[ ! "$addr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        if [[ -n "$addr" ]] && [[ ! "$addr" =~ ^(ip-only|no-sudo|help)$ ]]; then
            echo "Invalid IP address supplied. Defaulting to 192.168.1.0."
        fi
        addr="192.168.1.0"
    fi

    eval "${prefix}nmap $addr/$mask -n -sP${suffix}"
}
