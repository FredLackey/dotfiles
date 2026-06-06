#!/bin/bash
set -e

PREF_NAME="Keyboard Remapping"
DESIRED_OPTION="ctrl:nocaps"
CHANGES_MADE=false

echo "Configuring $PREF_NAME..."

# WSL terminal keyboard input is controlled by Windows and the terminal host.
# The Windows setup maps Caps Lock -> Left Ctrl for WSL shells. This GNOME
# setting is only useful for Linux GUI apps launched through WSLg.
if command -v gsettings >/dev/null 2>&1; then
    current_gsettings=$(gsettings get org.gnome.desktop.input-sources xkb-options 2>/dev/null || true)

    if [ -n "$current_gsettings" ] && ! echo "$current_gsettings" | grep -q "'$DESIRED_OPTION'"; then
        echo "Setting GNOME keyboard option $DESIRED_OPTION for WSLg apps..."
        if [ "$current_gsettings" = "@as []" ] || [ "$current_gsettings" = "[]" ]; then
            desired_gsettings="['$DESIRED_OPTION']"
        else
            desired_gsettings=$(printf '%s' "$current_gsettings" | sed "s/]$/, '$DESIRED_OPTION']/")
        fi

        gsettings set org.gnome.desktop.input-sources xkb-options "$desired_gsettings"
        CHANGES_MADE=true
    fi
fi

if command -v gsettings >/dev/null 2>&1; then
    verified_gsettings=$(gsettings get org.gnome.desktop.input-sources xkb-options 2>/dev/null || true)
    if [ -n "$verified_gsettings" ] && ! echo "$verified_gsettings" | grep -q "'$DESIRED_OPTION'"; then
        echo "Error: Failed to verify GNOME Caps Lock -> Control option."
        exit 1
    fi
fi

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied where WSL can control it."
else
    echo "$PREF_NAME already configured where WSL can control it."
fi
