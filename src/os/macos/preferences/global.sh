#!/bin/bash
set -e

PREF_NAME="Global Domain Preferences"
DOMAIN="NSGlobalDomain"
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

# --- Appearance ---

# Dark mode
set_default "AppleInterfaceStyle" "-string" "Dark"

# Auto-switch light/dark based on time of day
set_default "AppleInterfaceStyleSwitchesAutomatically" "-bool" "true"

# Always show scrollbars (not just when scrolling)
set_default "AppleShowScrollBars" "-string" "Always"

# Disable window open/close animations
set_default "NSAutomaticWindowAnimationsEnabled" "-bool" "false"

# Disable animated focus ring
set_default "NSUseAnimatedFocusRing" "-bool" "false"

# Don't minimize on title bar double-click
set_default "AppleMiniaturizeOnDoubleClick" "-bool" "false"

# --- Keyboard ---

# Full keyboard access (tab through all controls)
set_default "AppleKeyboardUIMode" "-int" "3"

# Disable press-and-hold for accent menu (enables key repeat)
set_default "ApplePressAndHoldEnabled" "-bool" "false"

# --- Text Correction (All Disabled) ---

# Disable auto-capitalization
set_default "NSAutomaticCapitalizationEnabled" "-bool" "false"

# Disable smart dashes (-- to em-dash)
set_default "NSAutomaticDashSubstitutionEnabled" "-bool" "false"

# Disable double-space to period
set_default "NSAutomaticPeriodSubstitutionEnabled" "-bool" "false"

# Disable smart quotes
set_default "NSAutomaticQuoteSubstitutionEnabled" "-bool" "false"

# Disable auto-correct
set_default "NSAutomaticSpellingCorrectionEnabled" "-bool" "false"

# --- Dialogs ---

# Expand save dialogs by default
set_default "NSNavPanelExpandedStateForSaveMode" "-bool" "true"
set_default "NSNavPanelExpandedStateForSaveMode2" "-bool" "true"

# --- Application Behavior ---

# Prevent apps from being auto-terminated when idle
set_default "NSDisableAutomaticTermination" "-bool" "true"

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied (log out or restart to take full effect)."
else
    echo "$PREF_NAME already configured."
fi
