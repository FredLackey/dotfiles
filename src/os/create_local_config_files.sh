#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_bash_local() {

    declare -r FILE_PATH="$HOME/.bash.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then

        DOTFILES_BIN_DIR="$(dirname "$(pwd)")/bin/"

        printf "%s\n" \
"#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set PATH additions.

PATH=\"$DOTFILES_BIN_DIR:\$PATH\"

export PATH" \
        >> "$FILE_PATH"
   fi

    print_result $? "$FILE_PATH"

}

create_gitconfig_local() {

    declare -r FILE_PATH="$HOME/.gitconfig.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [ ! -e "$FILE_PATH" ] || [ -z "$FILE_PATH" ]; then

        printf "%s\n" \
"[user]

    name =
    email =
    # signingkey =" \
        >> "$FILE_PATH"
    fi

    print_result $? "$FILE_PATH"

}

create_gnupg_config() {

    declare -r DIR_PATH="$HOME/.gnupg"
    declare -r FILE_PATH="$DIR_PATH/gpg-agent.conf"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Create .gnupg directory with secure permissions
    if [ ! -d "$DIR_PATH" ]; then
        mkdir -p "$DIR_PATH"
        chmod 700 "$DIR_PATH"
    fi

    # Create gpg-agent.conf if it doesn't exist
    if [ ! -e "$FILE_PATH" ]; then

        # Base configuration
        printf "%s\n" \
"default-cache-ttl 3600
max-cache-ttl 86400" \
        >> "$FILE_PATH"

        # Add pinentry-program for macOS
        if [ "$(uname)" == "Darwin" ]; then
            if [ "$(uname -m)" == "arm64" ]; then
                # Apple Silicon
                printf "%s\n" "pinentry-program /opt/homebrew/bin/pinentry-mac" >> "$FILE_PATH"
            else
                # Intel
                printf "%s\n" "pinentry-program /usr/local/bin/pinentry-mac" >> "$FILE_PATH"
            fi
        fi

        chmod 600 "$FILE_PATH"
    fi

    print_result $? "$FILE_PATH"

}

create_vimrc_local() {

    declare -r FILE_PATH="$HOME/.vimrc.local"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if [ ! -e "$FILE_PATH" ]; then
        printf "" >> "$FILE_PATH"
    fi

    print_result $? "$FILE_PATH"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n • Create local config files\n\n"

    create_bash_local
    create_gitconfig_local
    create_gnupg_config
    create_vimrc_local

}

main
