#!/bin/bash
set -e

PREF_NAME="Menu Bar Clock Preferences"
DOMAIN="com.apple.menuextra.clock"
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

# Show AM/PM indicator
set_default "ShowAMPM" "-bool" "true"

# Always show date in menu bar (0=Always, 1=When space allows, 2=Never)
set_default "ShowDate" "-int" "0"

# Show day of week
set_default "ShowDayOfWeek" "-bool" "true"

# Restart ControlCenter if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall ControlCenter 2>/dev/null || true
    echo "$PREF_NAME applied (ControlCenter restarted)."
else
    echo "$PREF_NAME already configured."
fi
