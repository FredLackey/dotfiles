#!/bin/bash
# org-by-date - Organize files into YYYY/MM/DD subdirectories
#
# Moves files with dates in their filenames into a directory structure
# based on the date (YYYY/MM/DD).
#
# Usage:
#   org-by-date
#
# Dependencies: None (uses built-in commands)

org-by-date() {
    ls -A1 | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' | while read -r line; do
        local dname
        dname="$(echo "$line" | grep -Eo '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}' | sed 's#-#/#g')"
        mkdir -p "./$dname"
        mv "$line" "./$dname/"
    done
}
