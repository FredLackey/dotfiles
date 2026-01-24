#!/bin/bash
set -e

APP_NAME="iTerm2"
APP_PATH="/Applications/iTerm.app"
ITERM2_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
THEME_URL_BASE="https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes"

# 1. Check if already installed
if [ -d "$APP_PATH" ] || brew list --cask iterm2 &>/dev/null; then
    echo "$APP_NAME is already installed."
else
    # 2. Check dependencies
    if ! command -v brew >/dev/null; then
        echo "Error: Homebrew is required to install $APP_NAME."
        exit 1
    fi

    # 3. Install
    echo "Installing $APP_NAME..."
    brew install --cask --quiet iterm2

    # 4. Verify
    if [ -d "$APP_PATH" ]; then
        echo "$APP_NAME installed successfully."
    else
        echo "Error: $APP_NAME installation failed."
        exit 1
    fi
fi

# 5. Install Solarized themes
if /usr/libexec/PlistBuddy -c "Print :'Custom Color Presets':'Solarized Dark'" "$ITERM2_PLIST" &>/dev/null; then
    echo "Solarized themes are already installed."
    exit 0
fi

echo "Installing Solarized themes..."

# Download theme files
curl -fsSL -o /tmp/SolarizedDark.itermcolors "$THEME_URL_BASE/iTerm2%20Solarized%20Dark.itermcolors"
curl -fsSL -o /tmp/SolarizedLight.itermcolors "$THEME_URL_BASE/iTerm2%20Solarized%20Light.itermcolors"

# Initialize iTerm2 plist if it does not exist
if [ ! -f "$ITERM2_PLIST" ]; then
    defaults write com.googlecode.iterm2 "Custom Color Presets" -dict
fi

# Add Custom Color Presets dictionary if it does not exist
/usr/libexec/PlistBuddy -c "Add :'Custom Color Presets' dict" "$ITERM2_PLIST" 2>/dev/null || true

# Import Solarized Dark preset
/usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Dark' dict" "$ITERM2_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Merge /tmp/SolarizedDark.itermcolors :'Custom Color Presets':'Solarized Dark'" "$ITERM2_PLIST"

# Import Solarized Light preset
/usr/libexec/PlistBuddy -c "Add :'Custom Color Presets':'Solarized Light' dict" "$ITERM2_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Merge /tmp/SolarizedLight.itermcolors :'Custom Color Presets':'Solarized Light'" "$ITERM2_PLIST"

# Set Solarized Dark as the default profile colors
/usr/libexec/PlistBuddy -c "Add :'New Bookmarks' array" "$ITERM2_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0 dict" "$ITERM2_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :'New Bookmarks':0:Name string Default" "$ITERM2_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Merge /tmp/SolarizedDark.itermcolors :'New Bookmarks':0" "$ITERM2_PLIST"

# Clean up downloaded files
rm -f /tmp/SolarizedDark.itermcolors /tmp/SolarizedLight.itermcolors

# 6. Verify themes installed
if /usr/libexec/PlistBuddy -c "Print :'Custom Color Presets':'Solarized Dark'" "$ITERM2_PLIST" &>/dev/null; then
    echo "Solarized themes installed. Solarized Dark set as default."
else
    echo "Error: Solarized theme installation failed."
    exit 1
fi
