#!/bin/bash
set -e

PREF_NAME="Dock Preferences"
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

# Helper: set an empty array only if not already empty
set_empty_array() {
    local key="$1"

    local current
    current=$(defaults read "$DOMAIN" "$key" 2>/dev/null || echo "__UNSET__")

    if [ "$current" = "(
)" ] || [ "$current" = "()" ]; then
        return
    fi

    defaults write "$DOMAIN" "$key" -array
    NEEDS_RESTART=true
}

# Auto-hide the Dock
set_default "autohide" "-bool" "true"

# No delay before Dock appears on hover
set_default "autohide-delay" "-float" "0"

# Disable bouncing animation on app launch
set_default "launchanim" "-bool" "false"

# Use scale effect when minimizing (instead of genie)
set_default "mineffect" "-string" "scale"

# Minimize windows into their app icon
set_default "minimize-to-application" "-bool" "true"

# Don't auto-rearrange Spaces based on most recent use
set_default "mru-spaces" "-bool" "false"

# Show dots under running apps
set_default "show-process-indicators" "-bool" "true"

# Don't show recent apps section in Dock
set_default "show-recents" "-bool" "false"

# Make hidden app icons translucent
set_default "showhidden" "-bool" "true"

# Enable spring-loading for all Dock items
set_default "enable-spring-load-actions-on-all-items" "-bool" "true"

# Don't group windows by app in Mission Control
set_default "expose-group-apps" "-bool" "false"

# No pinned apps (empty Dock)
set_empty_array "persistent-apps"

# No pinned folders or stacks
set_empty_array "persistent-others"

# Restart Dock if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall Dock 2>/dev/null || true
    echo "$PREF_NAME applied (Dock restarted)."
else
    echo "$PREF_NAME already configured."
fi
