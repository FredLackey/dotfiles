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

# Hide Focus icon from menu bar (24=Don't Show, 18=Always Show)
current=$(defaults -currentHost read com.apple.controlcenter FocusModes 2>/dev/null || echo "__UNSET__")
if [ "$current" != "24" ]; then
    defaults -currentHost write com.apple.controlcenter FocusModes -int 24
    NEEDS_RESTART=true
fi

# macOS Tahoe stores Control Center prefs in GroupContainers
GROUP_PLIST="$HOME/Library/GroupContainers/group.com.apple.controlcenter/Library/Preferences/group.com.apple.controlcenter"
if [ -d "$HOME/Library/GroupContainers/group.com.apple.controlcenter" ]; then
    current=$(defaults read "$GROUP_PLIST" FocusModes 2>/dev/null || echo "__UNSET__")
    if [ "$current" != "24" ]; then
        defaults write "$GROUP_PLIST" FocusModes -int 24
        NEEDS_RESTART=true
    fi
fi

# Restart ControlCenter if any changes were made
if [ "$NEEDS_RESTART" = true ]; then
    killall ControlCenter 2>/dev/null || true
    echo "$PREF_NAME applied (ControlCenter restarted)."
else
    echo "$PREF_NAME already configured."
fi
