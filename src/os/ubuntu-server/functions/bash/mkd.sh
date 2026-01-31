#!/bin/bash
# Create a new directory and enter it.
#
# Usage:
#   mkd my-new-folder

mkd() {
    mkdir -p "$@" && cd "$_" || return
}
