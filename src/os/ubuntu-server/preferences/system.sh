#!/bin/bash
set -e

PREF_NAME="System Preferences"
CHANGES_MADE=false

echo "Configuring $PREF_NAME..."

# =============================================================================
# Timezone
# =============================================================================

DESIRED_TIMEZONE="America/New_York"

current_tz=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "")

if [ "$current_tz" != "$DESIRED_TIMEZONE" ]; then
    echo "Setting timezone to $DESIRED_TIMEZONE..."
    sudo timedatectl set-timezone "$DESIRED_TIMEZONE"
    CHANGES_MADE=true
fi

# =============================================================================
# Locale
# =============================================================================

DESIRED_LOCALE="en_US.UTF-8"

# Check if locale is already generated
if ! locale -a 2>/dev/null | grep -q "^en_US.utf8$"; then
    echo "Generating locale $DESIRED_LOCALE..."
    sudo locale-gen "$DESIRED_LOCALE" >/dev/null 2>&1
    CHANGES_MADE=true
fi

# Check current default locale
current_locale=$(localectl status 2>/dev/null | grep "System Locale" | cut -d= -f2 || echo "")

if [ "$current_locale" != "$DESIRED_LOCALE" ]; then
    echo "Setting system locale to $DESIRED_LOCALE..."
    sudo update-locale LANG="$DESIRED_LOCALE" LC_ALL="$DESIRED_LOCALE"
    CHANGES_MADE=true
fi

# =============================================================================
# Keyboard Layout
# =============================================================================

DESIRED_LAYOUT="us"

current_layout=$(localectl status 2>/dev/null | grep "VC Keymap" | awk '{print $3}' || echo "")

if [ "$current_layout" != "$DESIRED_LAYOUT" ] && [ -n "$current_layout" ]; then
    echo "Setting keyboard layout to $DESIRED_LAYOUT..."
    sudo localectl set-keymap "$DESIRED_LAYOUT" 2>/dev/null || true
    CHANGES_MADE=true
fi

# =============================================================================
# NTP Time Sync
# =============================================================================

ntp_status=$(timedatectl show --property=NTP --value 2>/dev/null || echo "")

if [ "$ntp_status" != "yes" ]; then
    echo "Enabling NTP time synchronization..."
    sudo timedatectl set-ntp true
    CHANGES_MADE=true
fi

# =============================================================================
# Summary
# =============================================================================

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi
