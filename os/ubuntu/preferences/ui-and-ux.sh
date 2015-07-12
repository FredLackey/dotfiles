#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")" && source "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

set_ui_and_ux_settings() {

    execute 'gsettings set com.canonical.indicator.bluetooth visible false' \
        'Hide bluetooth icon from the menu bar'

    execute 'gsettings set com.canonical.indicator.sound visible false' \
        'Hide volume icon from the menu bar'

    execute 'gsettings set com.canonical.indicator.power icon-policy "charge" &&
             gsettings set com.canonical.indicator.power show-time false' \
        'Hide battery icon from the menu bar when the battery is not in use'

    execute 'gsettings set com.canonical.indicator.datetime custom-time-format "%l:%M %p" &&
             gsettings set com.canonical.indicator.datetime time-format "custom"' \
        'Use custom date format in the menu bar'

    execute 'gsettings set org.gnome.desktop.background picture-options "stretched"' \
        'Set desktop background image options'

    # execute 'gsettings set org.gnome.desktop.background picture-uri 'file:///home/...' &> /dev/null' \
    #     'Set desktop background image location'

    execute "gsettings set org.gnome.libgnomekbd.keyboard layouts \"[ 'us', 'ro' ]\"" \
        'Set keyboard languages'

    execute "gsettings set com.canonical.Unity.Launcher favorites \"[
        'ubiquity-gtkui.desktop',
        'nautilus-home.desktop',
        'chromium-browser.desktop',
        'google-chrome.desktop',
        'firefox.desktop',
        'firefox-trunk.desktop',
        'opera-browser.desktop',
        'opera-next-browser.desktop'
    ]\"" \
        'Set Launcher favorites'

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n  UI & UX\n\n"
    set_ui_and_ux_settings

}

main