#!/bin/bash
set -e

PREF_NAME="Hot Corners Preferences"
DOMAIN="com.apple.dock"
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

# Bottom-right corner: Quick Note (action 14)
set_default "wvous-br-corner" "-int" "14"
set_default "wvous-br-modifier" "-int" "0"

# Restart Dock if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall Dock 2>/dev/null || true
    echo "$PREF_NAME applied (Dock restarted)."
else
    echo "$PREF_NAME already configured."
fi
