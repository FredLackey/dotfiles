#!/bin/bash
set -e

APP_NAME="Terminal Theme"
THEME_NAME="Solarized Dark"
DOTFILES_DIR="$HOME/.dotfiles"
THEMES_DIR="$DOTFILES_DIR/src/os/macos/files/terminal"
APPLESCRIPT="$DOTFILES_DIR/src/os/macos/preferences/set_terminal_theme.applescript"
PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"

# 1. Check if Terminal.app default theme is already set
if [ -f "$PLIST" ]; then
    CURRENT_DEFAULT=$(/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" "$PLIST" 2>/dev/null || echo "")
    if [ "$CURRENT_DEFAULT" = "$THEME_NAME" ]; then
        echo "$APP_NAME is already configured."
        exit 0
    fi
fi

# 2. Check dependencies
if [ ! -d "$THEMES_DIR" ]; then
    echo "Error: Theme files not found at $THEMES_DIR"
    exit 1
fi

if [ ! -f "$APPLESCRIPT" ]; then
    echo "Error: AppleScript not found at $APPLESCRIPT"
    exit 1
fi

if [ ! -f "$THEMES_DIR/$THEME_NAME.terminal" ]; then
    echo "Error: Theme file '$THEME_NAME.terminal' not found."
    exit 1
fi

# 3. Remove quarantine attributes (files downloaded from GitHub may be quarantined)
echo "Configuring $APP_NAME..."
xattr -d com.apple.quarantine "$THEMES_DIR"/*.terminal 2>/dev/null || true
xattr -d com.apple.quarantine "$APPLESCRIPT" 2>/dev/null || true

# 4. Run the AppleScript to import and set the theme
echo "Importing '$THEME_NAME' theme into Terminal.app..."
osascript "$APPLESCRIPT" "$THEMES_DIR/$THEME_NAME.terminal"

# 5. Verify
CURRENT_DEFAULT=$(/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" "$PLIST" 2>/dev/null || echo "")
if [ "$CURRENT_DEFAULT" = "$THEME_NAME" ]; then
    echo "$APP_NAME configured."
else
    echo "Warning: Theme may not have been set as default. Manual verification recommended."
fi
