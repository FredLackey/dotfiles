#!/bin/bash
set -e

PREF_NAME="Finder Preferences"
DOMAIN="com.apple.finder"
NEEDS_RESTART=false

echo "Configuring $PREF_NAME..."

# Helper: set a defaults value only if it differs from desired
set_default() {
    local key="$1"
    local type="$2"
    local value="$3"

    local current
    current=$(defaults read "$DOMAIN" "$key" 2>/dev/null || echo "__UNSET__")

    if [ "$current" = "$value" ]; then
        return
    fi

    defaults write "$DOMAIN" "$key" "$type" "$value"
    NEEDS_RESTART=true
}

# Default to column view
set_default "FXPreferredViewStyle" "-string" "clmv"

# Show path bar at bottom of Finder windows
set_default "ShowPathbar" "-bool" "true"

# Search the current folder (not entire Mac)
set_default "FXDefaultSearchScope" "-string" "SCcf"

# No warning when changing file extensions
set_default "FXEnableExtensionChangeWarning" "-bool" "false"

# New Finder windows open to Desktop
set_default "NewWindowTarget" "-string" "PfDe"

# Desktop path for new windows
set_default "NewWindowTargetPath" "-string" "file://${HOME}/Desktop/"

# Show external drives on desktop
set_default "ShowExternalHardDrivesOnDesktop" "-bool" "true"

# Show hard drives on desktop
set_default "ShowHardDrivesOnDesktop" "-bool" "true"

# Show network volumes on desktop
set_default "ShowMountedServersOnDesktop" "-bool" "true"

# Show removable media on desktop
set_default "ShowRemovableMediaOnDesktop" "-bool" "true"

# Restart Finder if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall Finder 2>/dev/null || true
    echo "$PREF_NAME applied (Finder restarted)."
else
    echo "$PREF_NAME already configured."
fi
