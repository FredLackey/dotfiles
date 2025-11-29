#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Claude Code\n\n"

if ! cmd_exists "claude"; then
    execute \
        "curl -fsSL https://claude.ai/install.sh | bash" \
        "Claude Code"
else
    print_success "Claude Code"
fi

