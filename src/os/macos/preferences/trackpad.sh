#!/bin/bash
set -e

PREF_NAME="Trackpad Preferences"
DOMAIN="com.apple.AppleMultitouchTrackpad"
CHANGES_MADE=false

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
    CHANGES_MADE=true
}

# Tap to click enabled
set_default "Clicking" "-bool" "true"

# Two-finger tap for right-click
set_default "TrackpadRightClick" "-bool" "true"

# Haptic feedback on Force Touch
set_default "ActuateDetents" "-bool" "true"

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi
