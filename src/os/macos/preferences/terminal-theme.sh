#!/bin/bash
set -e

APP_NAME="Terminal Theme"
THEME_NAME="Solarized Dark"
DOTFILES_DIR="$HOME/.dotfiles"
THEMES_DIR="$DOTFILES_DIR/src/os/macos/files/terminal"
THEME_FILE="$THEMES_DIR/$THEME_NAME.terminal"
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
if [ ! -f "$THEME_FILE" ]; then
    echo "Error: Theme file '$THEME_NAME.terminal' not found at $THEMES_DIR"
    exit 1
fi

# 3. Remove quarantine attributes (files downloaded from GitHub may be quarantined)
echo "Configuring $APP_NAME..."
xattr -d com.apple.quarantine "$THEME_FILE" 2>/dev/null || true

# 4. Import theme directly into Terminal preferences using PlistBuddy
#    This is more reliable than using AppleScript with 'open'
echo "Importing '$THEME_NAME' theme into Terminal.app..."

# Check if the theme already exists in Window Settings
THEME_EXISTS=$(/usr/libexec/PlistBuddy -c "Print 'Window Settings:$THEME_NAME'" "$PLIST" 2>/dev/null && echo "yes" || echo "no")

if [ "$THEME_EXISTS" = "no" ]; then
    # Import the theme by merging the .terminal plist into Window Settings
    /usr/libexec/PlistBuddy -c "Add 'Window Settings:$THEME_NAME' dict" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Merge '$THEME_FILE' 'Window Settings:$THEME_NAME'" "$PLIST"
fi

# 5. Set theme as default for new windows and startup
/usr/libexec/PlistBuddy -c "Set 'Default Window Settings' '$THEME_NAME'" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add 'Default Window Settings' string '$THEME_NAME'" "$PLIST"

/usr/libexec/PlistBuddy -c "Set 'Startup Window Settings' '$THEME_NAME'" "$PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add 'Startup Window Settings' string '$THEME_NAME'" "$PLIST"

# 6. Verify
CURRENT_DEFAULT=$(/usr/libexec/PlistBuddy -c "Print 'Default Window Settings'" "$PLIST" 2>/dev/null || echo "")
if [ "$CURRENT_DEFAULT" = "$THEME_NAME" ]; then
    echo "$APP_NAME configured."
else
    echo "Warning: Theme may not have been set as default. Manual verification recommended."
fi
