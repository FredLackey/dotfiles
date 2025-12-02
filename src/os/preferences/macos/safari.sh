#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Note: Starting with macOS Ventura (13) and especially Sequoia (15+),
# Safari preferences are heavily sandboxed. Apple no longer allows
# programmatic modification of most Safari settings via `defaults write`.
# This script attempts settings that may work but skips gracefully on failure.

print_in_purple "\n   Safari\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable the 'Develop' menu and 'Web Inspector'
# This is one of the few settings that still works via SandboxBroker
execute "defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true 2>/dev/null; \
         defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null; \
         defaults write -g WebKitDeveloperExtras -bool true 2>/dev/null; \
         true" \
    "Enable the 'Develop' menu and the 'Web Inspector'"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

killall "Safari" &> /dev/null

print_warning "Safari settings are restricted on macOS 15+"
print_warning "Configure manually: Safari > Settings > Advanced > Show features for web developers"
print_warning "Other preferences must be set through Safari's Settings menu"
