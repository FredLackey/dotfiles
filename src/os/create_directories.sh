#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_directories() {

    declare -a DIRECTORIES=(
        "$HOME/Backups"
        "$HOME/Downloads/_Source"
        "$HOME/Downloads/_Torrents"
        "$HOME/Downloads/_YouTube"

        "$HOME/Screenshots"
        "$HOME/Temporary"
        "$HOME/Source"
        "$HOME/Source/AWS"
        "$HOME/Source/Bitbucket"
        "$HOME/Source/GitHub"
    )

    for i in "${DIRECTORIES[@]}"; do
        mkd "$i"
    done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n • Create directories\n\n"
    create_directories
}

main
