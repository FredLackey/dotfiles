#!/bin/bash
# killni - Kill Node Inspector processes
#
# Kills all processes running 'node --debug-brk'.
#
# Usage:
#   killni
#
# Dependencies: None (uses built-in commands)

killni() {
    local target='node --debug-brk'
    ps -ef | grep "$target" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
    echo "Node Inspector processes killed."
}
