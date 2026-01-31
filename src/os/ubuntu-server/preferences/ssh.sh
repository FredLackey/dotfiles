#!/bin/bash
set -e

PREF_NAME="SSH Server Preferences"
CHANGES_MADE=false
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"
CUSTOM_CONFIG="$SSHD_CONFIG_DIR/99-custom.conf"

echo "Configuring $PREF_NAME..."

# =============================================================================
# Check if SSH server is installed
# =============================================================================

if ! command -v sshd >/dev/null 2>&1; then
    echo "SSH server (sshd) is not installed. Skipping SSH preferences."
    exit 0
fi

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "SSH config file not found at $SSHD_CONFIG. Skipping SSH preferences."
    exit 0
fi

# =============================================================================
# Helper Functions
# =============================================================================

# Get current SSH config value (checks both main config and config.d directory)
get_sshd_value() {
    local key="$1"
    local value=""

    # Check custom config first
    if [ -f "$CUSTOM_CONFIG" ]; then
        value=$(grep -E "^${key}\s+" "$CUSTOM_CONFIG" 2>/dev/null | awk '{print $2}' | head -1)
    fi

    # Fall back to main config if not in custom
    if [ -z "$value" ]; then
        value=$(grep -E "^${key}\s+" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}' | head -1)
    fi

    echo "$value"
}

# Build the custom SSH config content
build_custom_config() {
    cat << 'EOF'
# Custom SSH server configuration
# Managed by dotfiles - do not edit manually

# Security: Disable root login
PermitRootLogin no

# Security: Disable password authentication (use keys only)
# Note: Uncomment the line below ONLY after setting up SSH keys
# PasswordAuthentication no

# Security: Disable empty passwords
PermitEmptyPasswords no

# Security: Limit authentication attempts
MaxAuthTries 3

# Security: Disconnect idle sessions after 10 minutes
ClientAliveInterval 300
ClientAliveCountMax 2

# Security: Use only protocol 2
Protocol 2

# Security: Disable X11 forwarding (not needed on servers)
X11Forwarding no

# Performance: Enable compression
Compression yes

# Logging: Log authentication attempts
LogLevel VERBOSE
EOF
}

# =============================================================================
# Apply SSH Configuration
# =============================================================================

# Ensure the config.d directory exists
if [ ! -d "$SSHD_CONFIG_DIR" ]; then
    echo "Creating SSH config directory..."
    sudo mkdir -p "$SSHD_CONFIG_DIR"
    CHANGES_MADE=true
fi

# Check if our custom config needs to be created or updated
DESIRED_CONFIG=$(build_custom_config)

if [ -f "$CUSTOM_CONFIG" ]; then
    CURRENT_CONFIG=$(sudo cat "$CUSTOM_CONFIG" 2>/dev/null || echo "")
    if [ "$CURRENT_CONFIG" != "$DESIRED_CONFIG" ]; then
        echo "Updating custom SSH configuration..."
        echo "$DESIRED_CONFIG" | sudo tee "$CUSTOM_CONFIG" > /dev/null
        CHANGES_MADE=true
    fi
else
    echo "Creating custom SSH configuration..."
    echo "$DESIRED_CONFIG" | sudo tee "$CUSTOM_CONFIG" > /dev/null
    sudo chmod 644 "$CUSTOM_CONFIG"
    CHANGES_MADE=true
fi

# =============================================================================
# Validate and Reload
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    # Validate SSH configuration before reloading
    echo "Validating SSH configuration..."
    if sudo sshd -t 2>/dev/null; then
        echo "SSH configuration is valid."

        # Reload SSH service to apply changes
        if systemctl is-active --quiet sshd 2>/dev/null; then
            echo "Reloading SSH service..."
            sudo systemctl reload sshd
        elif systemctl is-active --quiet ssh 2>/dev/null; then
            echo "Reloading SSH service..."
            sudo systemctl reload ssh
        fi
    else
        echo "Error: SSH configuration is invalid. Reverting changes..."
        sudo rm -f "$CUSTOM_CONFIG"
        exit 1
    fi
fi

# =============================================================================
# Summary
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
    echo ""
    echo "IMPORTANT: Before enabling 'PasswordAuthentication no', ensure you have:"
    echo "  1. Added your SSH public key to ~/.ssh/authorized_keys"
    echo "  2. Tested SSH key authentication successfully"
    echo "  3. Then edit $CUSTOM_CONFIG to uncomment PasswordAuthentication"
else
    echo "$PREF_NAME already configured."
fi
