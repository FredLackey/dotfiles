#!/bin/bash
set -e

PREF_NAME="TextEdit Preferences"
DOMAIN="com.apple.TextEdit"
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

# Default to plain text mode (not rich text)
set_default "RichText" "-bool" "false"

# Use UTF-8 encoding when reading files
set_default "PlainTextEncoding" "-int" "4"

# Use UTF-8 encoding when writing files
set_default "PlainTextEncodingForWrite" "-int" "4"

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied (takes effect on next TextEdit launch)."
else
    echo "$PREF_NAME already configured."
fi
