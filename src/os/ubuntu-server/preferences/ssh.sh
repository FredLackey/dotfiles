#!/bin/bash
set -e

PREF_NAME="SSH Server Preferences"
CHANGES_MADE=false
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_DIR="/etc/ssh/sshd_config.d"

# Use a numerically-low filename so our directives win precedence over cloud-init
# (sshd reads config.d in alphanumeric order; first occurrence of each directive wins).
HARDENING_CONFIG="$SSHD_CONFIG_DIR/01-hardening.conf"

# Legacy filename from older versions of this script. Removed if found.
LEGACY_CONFIG="$SSHD_CONFIG_DIR/99-custom.conf"

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

# Return 0 if the given authorized_keys file has at least one usable key entry
# (non-empty line that is not a comment).
has_usable_key() {
    local file="$1"
    [ -f "$file" ] || return 1
    sudo grep -E '^[^#[:space:]]' "$file" >/dev/null 2>&1
}

# Decide whether it is safe to disable password authentication.
# Safe = at least one user that can SSH in has key-based auth configured.
# We check the invoking user's authorized_keys and root's authorized_keys.
can_disable_password_auth() {
    # Invoking user (the human running the dotfiles, even via sudo)
    local invoking_user="${SUDO_USER:-$USER}"
    local invoking_home
    invoking_home=$(getent passwd "$invoking_user" 2>/dev/null | cut -d: -f6)

    if [ -n "$invoking_home" ] && has_usable_key "$invoking_home/.ssh/authorized_keys"; then
        return 0
    fi

    if has_usable_key "/root/.ssh/authorized_keys"; then
        return 0
    fi

    return 1
}

# Decide whether it is safe to disable root SSH login.
# Safe = a non-root user with sudo privileges AND a usable authorized_keys exists.
# Without this check, disabling PermitRootLogin on a root-only box locks the operator out.
can_disable_root_login() {
    # Walk every account in the sudo group; any one with key auth is sufficient.
    local sudoers
    sudoers=$(getent group sudo 2>/dev/null | cut -d: -f4 | tr ',' ' ')
    [ -n "$sudoers" ] || return 1

    local user home
    for user in $sudoers; do
        [ "$user" = "root" ] && continue
        home=$(getent passwd "$user" 2>/dev/null | cut -d: -f6)
        [ -n "$home" ] || continue
        if has_usable_key "$home/.ssh/authorized_keys"; then
            return 0
        fi
    done
    return 1
}

# Build the hardening config content based on what is safe to enforce.
build_hardening_config() {
    local password_directive="$1"   # "PasswordAuthentication no" or comment
    local root_directive="$2"       # "PermitRootLogin no" or comment

    cat << EOF
# SSH server hardening — managed by dotfiles.
# Loaded before /etc/ssh/sshd_config.d/50-cloud-init.conf so these directives
# win precedence (sshd uses first-occurrence semantics within config.d).
# Do not edit manually — re-run the dotfiles preference script instead.

# Authentication
$password_directive
PermitEmptyPasswords no
$root_directive

# Limit per-connection auth attempts. Default OpenSSH value is 6; we keep that
# to avoid spurious "Too many authentication failures" when ssh-agent offers
# several keys. Tighten only if you know your client offers a single key.
MaxAuthTries 6

# Idle session disconnect (5 min interval × 2 = ~10 min before kicked out)
ClientAliveInterval 300
ClientAliveCountMax 2

# Disable X11 forwarding on servers
X11Forwarding no

# Performance
Compression yes

# Verbose auth logging
LogLevel VERBOSE
EOF
}

# =============================================================================
# Decide what to enforce
# =============================================================================

if can_disable_password_auth; then
    PASSWORD_DIRECTIVE="PasswordAuthentication no"
    PASSWORD_STATUS="enforced (key-based auth detected)"
else
    PASSWORD_DIRECTIVE="# PasswordAuthentication no  # not enforced: no usable authorized_keys found"
    PASSWORD_STATUS="NOT enforced (no usable authorized_keys for the invoking user or root)"
fi

# PermitRootLogin: opt-in only, and only when a non-root sudoer with key auth exists.
DISABLE_ROOT="${DOTFILES_SSH_DISABLE_ROOT:-false}"
if [ "$DISABLE_ROOT" = "true" ] && can_disable_root_login; then
    ROOT_DIRECTIVE="PermitRootLogin no"
    ROOT_STATUS="enforced (sudoer with key auth exists)"
elif [ "$DISABLE_ROOT" = "true" ]; then
    ROOT_DIRECTIVE="# PermitRootLogin no  # requested but unsafe: no non-root sudoer with key auth"
    ROOT_STATUS="NOT enforced (would lock out root with no fallback)"
else
    ROOT_DIRECTIVE="# PermitRootLogin not managed (set DOTFILES_SSH_DISABLE_ROOT=true to opt in)"
    ROOT_STATUS="not managed (system default)"
fi

# =============================================================================
# Apply configuration
# =============================================================================

# Ensure config.d directory exists
if [ ! -d "$SSHD_CONFIG_DIR" ]; then
    echo "Creating SSH config directory..."
    sudo mkdir -p "$SSHD_CONFIG_DIR"
    CHANGES_MADE=true
fi

# Migrate from legacy 99-custom.conf — that file was always script-managed,
# so removing it is safe. It had the side effect of being overridden by
# cloud-init due to filename ordering, which is the bug we're fixing.
if [ -f "$LEGACY_CONFIG" ]; then
    echo "Removing legacy $LEGACY_CONFIG (superseded by $HARDENING_CONFIG)..."
    sudo rm -f "$LEGACY_CONFIG"
    CHANGES_MADE=true
fi

DESIRED_CONFIG=$(build_hardening_config "$PASSWORD_DIRECTIVE" "$ROOT_DIRECTIVE")

if [ -f "$HARDENING_CONFIG" ]; then
    CURRENT_CONFIG=$(sudo cat "$HARDENING_CONFIG" 2>/dev/null || echo "")
    if [ "$CURRENT_CONFIG" != "$DESIRED_CONFIG" ]; then
        echo "Updating $HARDENING_CONFIG..."
        echo "$DESIRED_CONFIG" | sudo tee "$HARDENING_CONFIG" > /dev/null
        sudo chmod 644 "$HARDENING_CONFIG"
        CHANGES_MADE=true
    fi
else
    echo "Creating $HARDENING_CONFIG..."
    echo "$DESIRED_CONFIG" | sudo tee "$HARDENING_CONFIG" > /dev/null
    sudo chmod 644 "$HARDENING_CONFIG"
    CHANGES_MADE=true
fi

# =============================================================================
# Validate, reload, verify
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    echo "Validating SSH configuration..."
    if ! sudo sshd -t 2>/dev/null; then
        echo "Error: sshd -t reports invalid configuration. Reverting."
        sudo rm -f "$HARDENING_CONFIG"
        exit 1
    fi
    echo "SSH configuration is valid."

    if systemctl is-active --quiet sshd 2>/dev/null; then
        echo "Reloading sshd..."
        sudo systemctl reload sshd
    elif systemctl is-active --quiet ssh 2>/dev/null; then
        echo "Reloading ssh..."
        sudo systemctl reload ssh
    fi

    # Verify effective configuration matches our intent. sshd -T prints the
    # actual runtime values, accounting for cloud-init and any other config.d
    # files. This is the only way to confirm our directives actually won.
    EFFECTIVE_PASSWORD=$(sudo sshd -T 2>/dev/null | awk '/^passwordauthentication/ {print $2}')
    EFFECTIVE_ROOT=$(sudo sshd -T 2>/dev/null | awk '/^permitrootlogin/ {print $2}')

    if [ "$PASSWORD_DIRECTIVE" = "PasswordAuthentication no" ] && [ "$EFFECTIVE_PASSWORD" != "no" ]; then
        echo "Warning: PasswordAuthentication is effectively '$EFFECTIVE_PASSWORD' after reload."
        echo "Another file in $SSHD_CONFIG_DIR or $SSHD_CONFIG may be overriding $HARDENING_CONFIG."
        echo "Inspect with: sudo sshd -T | grep -i passwordauthentication"
    fi

    if [ "$ROOT_DIRECTIVE" = "PermitRootLogin no" ] && [ "$EFFECTIVE_ROOT" != "no" ]; then
        echo "Warning: PermitRootLogin is effectively '$EFFECTIVE_ROOT' after reload."
        echo "Another file in $SSHD_CONFIG_DIR or $SSHD_CONFIG may be overriding $HARDENING_CONFIG."
        echo "Inspect with: sudo sshd -T | grep -i permitrootlogin"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi

echo "  PasswordAuthentication: $PASSWORD_STATUS"
echo "  PermitRootLogin:        $ROOT_STATUS"
