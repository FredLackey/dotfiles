#!/bin/bash
set -e

PREF_NAME="WSL Configuration"
WSL_CONF="/etc/wsl.conf"

echo "Configuring $PREF_NAME..."

DESIRED_CONF="[interop]
enabled = true
appendWindowsPath = true

[user]
default = $(whoami)"

CURRENT_CONF=""
if [ -f "$WSL_CONF" ]; then
    CURRENT_CONF=$(sudo cat "$WSL_CONF" 2>/dev/null || echo "")
fi

if [ "$CURRENT_CONF" = "$DESIRED_CONF" ]; then
    echo "$PREF_NAME already configured."
    exit 0
fi

echo "Writing $WSL_CONF..."
echo "$DESIRED_CONF" | sudo tee "$WSL_CONF" > /dev/null
sudo chmod 644 "$WSL_CONF"

echo "$PREF_NAME applied."
echo "Note: Changes to wsl.conf take effect after restarting WSL ('wsl --shutdown' from Windows PowerShell)."
