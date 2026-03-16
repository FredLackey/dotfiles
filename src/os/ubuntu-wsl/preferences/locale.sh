#!/bin/bash
set -e

PREF_NAME="Locale"
CHANGES_MADE=false
DESIRED_LOCALE="en_US.UTF-8"

echo "Configuring $PREF_NAME..."

if ! locale -a 2>/dev/null | grep -q "^en_US.utf8$"; then
    echo "Generating locale $DESIRED_LOCALE..."
    if sudo locale-gen "$DESIRED_LOCALE" >/dev/null 2>&1; then
        CHANGES_MADE=true
    else
        echo "Note: Failed to generate locale."
    fi
fi

if sudo update-locale LANG="$DESIRED_LOCALE" LC_ALL="$DESIRED_LOCALE" 2>/dev/null; then
    : # already set or set now
else
    echo "Note: update-locale not available, skipping."
fi

if [ "$CHANGES_MADE" = true ]; then
    echo "$PREF_NAME applied."
else
    echo "$PREF_NAME already configured."
fi
