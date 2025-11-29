#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Note: Starting with macOS Monterey (12) and later, Safari preferences
# are sandboxed. Many settings now require writing to the container path
# or using different preference domains.

print_in_purple "\n   Safari\n\n"

# Get current user for container path
CURRENT_USER=$(whoami)
SAFARI_CONTAINER="$HOME/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Disable opening 'safe' files automatically
execute "defaults write com.apple.Safari AutoOpenSafeDownloads -bool false && \
         defaults write '$SAFARI_CONTAINER' AutoOpenSafeDownloads -bool false" \
    "Disable opening 'safe' files automatically"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Enable the 'Develop' menu and 'Web Inspector'
# macOS 12+ requires SandboxBroker domain
execute "defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
         defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
         defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true && \
         defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
         defaults write -g WebKitDeveloperExtras -bool true" \
    "Enable the 'Develop' menu and the 'Web Inspector'"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

execute "defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false" \
    "Set search type to 'Contains' instead of 'Starts With'"

execute "defaults write com.apple.Safari HomePage -string 'about:blank'" \
    "Set home page to 'about:blank'"

execute "defaults write com.apple.Safari ShowFavoritesBar -bool false" \
    "Hide bookmarks bar by default"

execute "defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true" \
    "Show the full URL in the address bar"

execute "defaults write com.apple.Safari SuppressSearchSuggestions -bool true && \
         defaults write com.apple.Safari UniversalSearchEnabled -bool false" \
    "Don't send search queries to Apple"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Note: The following settings may not work on macOS 15+ due to
# increased security restrictions. They are kept for compatibility
# with older systems but may silently fail on newer versions.

# execute "defaults write com.apple.Safari IncludeInternalDebugMenu -bool true" \
#     "Enable 'Debug' menu"

# execute "defaults write com.apple.Safari WebKitInitialTimedLayoutDelay 0.25" \
#     "Disable the standard delay in rendering a web page."

# execute "defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true" \
#     "Set backspace key to go to the previous page in history"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

killall "Safari" &> /dev/null

print_warning "Some Safari settings may require Full Disk Access for Terminal"
print_warning "System Settings > Privacy & Security > Full Disk Access"
