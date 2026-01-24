#!/bin/bash
set -e

PREF_NAME="Menu Bar Preferences"
NEEDS_RESTART=false

echo "Configuring $PREF_NAME..."

# Hide Spotlight icon from menu bar
current=$(defaults -currentHost read com.apple.Spotlight MenuItemHidden 2>/dev/null || echo "__UNSET__")
if [ "$current" != "1" ]; then
    defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1
fi

# Hide Focus icon from menu bar
current=$(defaults read com.apple.controlcenter "NSStatusItem VisibleCC FocusModes" 2>/dev/null || echo "__UNSET__")
if [ "$current" != "0" ]; then
    defaults write com.apple.controlcenter "NSStatusItem VisibleCC FocusModes" -bool false
    NEEDS_RESTART=true
fi

# Restart ControlCenter if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall ControlCenter 2>/dev/null || true
    echo "$PREF_NAME applied (ControlCenter restarted)."
else
    echo "$PREF_NAME already configured."
fi
