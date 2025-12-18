#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare -r GITEGO_REPO="github.com/bgreenwell/gitego"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_gitego() {

    # Ensure Go bin directory is in PATH for this session
    export PATH="$HOME/go/bin:$PATH"

    execute \
        "go install ${GITEGO_REPO}@main" \
        "gitego (install from source)"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   gitego\n\n"

    # Check if Go is available
    if ! cmd_exists "go"; then
        print_error "gitego (Go is not installed - skipping)"
        return 1
    fi

    # Install or update gitego
    if ! cmd_exists "gitego"; then
        install_gitego
    else
        print_success "gitego"
    fi

}

main
