#!/bin/bash
set -e

PREF_NAME="Screenshot Preferences"
DOMAIN="com.apple.screencapture"
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

# Create screenshots directory if it doesn't exist
if [ ! -d "${HOME}/Screenshots" ]; then
    mkdir -p "${HOME}/Screenshots"
    echo "Created ~/Screenshots directory."
fi

# No window shadow in window screenshots
set_default "disable-shadow" "-bool" "true"

# Save screenshots to ~/Screenshots
set_default "location" "-string" "${HOME}/Screenshots"

# No floating thumbnail preview after capture
set_default "show-thumbnail" "-bool" "false"

# Save as PNG format
set_default "type" "-string" "png"

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi
