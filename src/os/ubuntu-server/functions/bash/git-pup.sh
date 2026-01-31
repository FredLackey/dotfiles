#!/bin/bash
# Pull changes and update git submodules.
#
# Usage:
#   git-pup

git-pup() {
    git pull && git submodule init && git submodule update && git submodule status
}
