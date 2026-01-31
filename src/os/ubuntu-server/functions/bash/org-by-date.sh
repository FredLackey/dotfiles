#!/bin/bash
# Organize files in the current directory into subdirectories based on date in filename.
#
# Usage:
#   org-by-date

org-by-date() {
    ls -A1 | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' | while read -r line; do
        DNAME="$(echo "$line" | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sed 's#-#/#g')"
        mkdir -p "./$DNAME"
        mv "$line" "./$DNAME/"
    done
}
