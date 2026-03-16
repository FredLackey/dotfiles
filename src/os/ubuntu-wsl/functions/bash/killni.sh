#!/bin/bash
# Kill Node Inspector processes.
#
# Usage:
#   killni

killni() {
    local killni_target='node --debug-brk'
    ps -ef | grep "$killni_target" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
}
