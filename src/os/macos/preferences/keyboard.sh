#!/bin/bash
set -e

PREF_NAME="Keyboard Remapping"
CHANGES_MADE=false

SCRIPT_PATH="$HOME/.local/bin/dotfiles-remap-caps-lock-macos.sh"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_AGENTS_DIR/com.fredlackey.dotfiles.capslock-control.plist"
LOG_PATH="$HOME/Library/Logs/dotfiles-capslock-control.log"

CAPS_LOCK_USAGE="0x700000039"
LEFT_CONTROL_USAGE="0x7000000E0"
CAPS_LOCK_DECIMAL="30064771129"
LEFT_CONTROL_DECIMAL="30064771296"

echo "Configuring $PREF_NAME..."

mkdir -p "$(dirname "$SCRIPT_PATH")" "$LAUNCH_AGENTS_DIR" "$(dirname "$LOG_PATH")"

DESIRED_SCRIPT=$(cat <<'EOF'
#!/bin/bash
set -e

# macOS hidutil mappings are session-scoped. This script is run directly by
# setup and by a LaunchAgent at login so the mapping survives restarts.
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'
EOF
)

if [ ! -f "$SCRIPT_PATH" ] || [ "$(cat "$SCRIPT_PATH")" != "$DESIRED_SCRIPT" ]; then
    echo "Writing Caps Lock remap helper..."
    printf '%s\n' "$DESIRED_SCRIPT" > "$SCRIPT_PATH"
    chmod 755 "$SCRIPT_PATH"
    CHANGES_MADE=true
elif [ ! -x "$SCRIPT_PATH" ]; then
    chmod 755 "$SCRIPT_PATH"
    CHANGES_MADE=true
fi

DESIRED_PLIST=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.fredlackey.dotfiles.capslock-control</string>
    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$LOG_PATH</string>
    <key>StandardErrorPath</key>
    <string>$LOG_PATH</string>
</dict>
</plist>
EOF
)

if [ ! -f "$PLIST_PATH" ] || [ "$(cat "$PLIST_PATH")" != "$DESIRED_PLIST" ]; then
    echo "Writing LaunchAgent for Caps Lock remap..."
    printf '%s\n' "$DESIRED_PLIST" > "$PLIST_PATH"
    chmod 644 "$PLIST_PATH"
    CHANGES_MADE=true
fi

is_mapping_active() {
    local current
    current=$(hidutil property --get UserKeyMapping 2>/dev/null || true)

    if echo "$current" | grep -q "$CAPS_LOCK_USAGE" && echo "$current" | grep -q "$LEFT_CONTROL_USAGE"; then
        return 0
    fi

    if echo "$current" | grep -q "$CAPS_LOCK_DECIMAL" && echo "$current" | grep -q "$LEFT_CONTROL_DECIMAL"; then
        return 0
    fi

    return 1
}

if ! is_mapping_active; then
    echo "Applying Caps Lock -> Left Control mapping..."
    "$SCRIPT_PATH"
    CHANGES_MADE=true
fi

if command -v launchctl >/dev/null 2>&1; then
    launchctl bootout "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1 || true
    if launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH" >/dev/null 2>&1; then
        launchctl enable "gui/$(id -u)/com.fredlackey.dotfiles.capslock-control" >/dev/null 2>&1 || true
    else
        echo "Warning: Could not load LaunchAgent. It should load after the next login."
    fi
fi

if ! is_mapping_active; then
    echo "Error: Failed to verify Caps Lock -> Left Control mapping."
    exit 1
fi

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied (Caps Lock -> Left Control)."
else
    echo "$PREF_NAME already configured (Caps Lock -> Left Control)."
fi
