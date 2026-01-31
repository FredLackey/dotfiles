#!/bin/bash
# Set git user email and name to public defaults.
#
# Usage:
#   set-git-public

set-git-public() {
    git config user.email "fred.lackey@gmail.com"
    git config user.name "Fred Lackey"
}
