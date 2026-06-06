#!/bin/bash
set -e

PREF_NAME="Keyboard Remapping"
CHANGES_MADE=false

KEYBOARD_FILE="/etc/default/keyboard"
DESIRED_OPTION="ctrl:nocaps"

echo "Configuring $PREF_NAME..."

option_list_has_value() {
    local value="$1"
    local desired="$2"

    echo ",$value," | grep -q ",$desired,"
}

normalize_options() {
    local value="$1"

    value="${value// /}"
    value="${value#,}"
    value="${value%,}"
    printf '%s' "$value"
}

current_options=""
if [ -f "$KEYBOARD_FILE" ]; then
    current_options=$(grep -E '^XKBOPTIONS=' "$KEYBOARD_FILE" | tail -n 1 | cut -d= -f2- | tr -d '"')
fi
current_options=$(normalize_options "$current_options")

desired_options="$current_options"
if ! option_list_has_value "$current_options" "$DESIRED_OPTION"; then
    if [ -n "$desired_options" ]; then
        desired_options="$desired_options,$DESIRED_OPTION"
    else
        desired_options="$DESIRED_OPTION"
    fi
fi

if [ "$current_options" != "$desired_options" ]; then
    echo "Setting Caps Lock -> Control in $KEYBOARD_FILE..."
    temp_file=$(mktemp)

    if [ -f "$KEYBOARD_FILE" ]; then
        if grep -qE '^XKBOPTIONS=' "$KEYBOARD_FILE"; then
            sed "s/^XKBOPTIONS=.*/XKBOPTIONS=\"$desired_options\"/" "$KEYBOARD_FILE" > "$temp_file"
        else
            cat "$KEYBOARD_FILE" > "$temp_file"
            printf 'XKBOPTIONS="%s"\n' "$desired_options" >> "$temp_file"
        fi
    else
        {
            echo 'XKBMODEL="pc105"'
            echo 'XKBLAYOUT="us"'
            echo 'XKBVARIANT=""'
            printf 'XKBOPTIONS="%s"\n' "$desired_options"
            echo 'BACKSPACE="guess"'
        } > "$temp_file"
    fi

    sudo install -m 644 "$temp_file" "$KEYBOARD_FILE"
    rm -f "$temp_file"
    CHANGES_MADE=true
fi

if command -v localectl >/dev/null 2>&1 && localectl status >/dev/null 2>&1; then
    current_layout=$(localectl status 2>/dev/null | awk -F: '/X11 Layout/ {gsub(/^ +/, "", $2); print $2; exit}')
    current_model=$(localectl status 2>/dev/null | awk -F: '/X11 Model/ {gsub(/^ +/, "", $2); print $2; exit}')
    current_variant=$(localectl status 2>/dev/null | awk -F: '/X11 Variant/ {gsub(/^ +/, "", $2); print $2; exit}')
    current_x11_options=$(localectl status 2>/dev/null | awk -F: '/X11 Options/ {gsub(/^ +/, "", $2); print $2; exit}')

    current_layout="${current_layout:-us}"
    current_model="${current_model:-pc105}"
    current_variant="${current_variant:-}"
    current_x11_options=$(normalize_options "$current_x11_options")

    desired_x11_options="$current_x11_options"
    if ! option_list_has_value "$current_x11_options" "$DESIRED_OPTION"; then
        if [ -n "$desired_x11_options" ]; then
            desired_x11_options="$desired_x11_options,$DESIRED_OPTION"
        else
            desired_x11_options="$DESIRED_OPTION"
        fi
    fi

    if [ "$current_x11_options" != "$desired_x11_options" ]; then
        echo "Setting X11 keyboard option $DESIRED_OPTION..."
        sudo localectl --no-convert set-x11-keymap "$current_layout" "$current_model" "$current_variant" "$desired_x11_options"
        CHANGES_MADE=true
    fi
fi

if command -v gsettings >/dev/null 2>&1; then
    current_gsettings=$(gsettings get org.gnome.desktop.input-sources xkb-options 2>/dev/null || true)

    if [ -n "$current_gsettings" ] && ! echo "$current_gsettings" | grep -q "'$DESIRED_OPTION'"; then
        echo "Setting GNOME keyboard option $DESIRED_OPTION..."
        if [ "$current_gsettings" = "@as []" ] || [ "$current_gsettings" = "[]" ]; then
            desired_gsettings="['$DESIRED_OPTION']"
        else
            desired_gsettings=$(printf '%s' "$current_gsettings" | sed "s/]$/, '$DESIRED_OPTION']/")
        fi

        gsettings set org.gnome.desktop.input-sources xkb-options "$desired_gsettings"
        CHANGES_MADE=true
    fi
fi

verified_options=$(grep -E '^XKBOPTIONS=' "$KEYBOARD_FILE" 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '"')
verified_options=$(normalize_options "$verified_options")

if ! option_list_has_value "$verified_options" "$DESIRED_OPTION"; then
    echo "Error: Failed to verify Caps Lock -> Control in $KEYBOARD_FILE."
    exit 1
fi

if command -v gsettings >/dev/null 2>&1; then
    verified_gsettings=$(gsettings get org.gnome.desktop.input-sources xkb-options 2>/dev/null || true)
    if [ -n "$verified_gsettings" ] && ! echo "$verified_gsettings" | grep -q "'$DESIRED_OPTION'"; then
        echo "Error: Failed to verify GNOME Caps Lock -> Control option."
        exit 1
    fi
fi

if command -v setupcon >/dev/null 2>&1; then
    sudo setupcon >/dev/null 2>&1 || true
fi

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied (Caps Lock -> Control)."
else
    echo "$PREF_NAME already configured (Caps Lock -> Control)."
fi
