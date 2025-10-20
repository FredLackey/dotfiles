#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Cleanup\n\n"

# Remove packages that were automatically installed to satisfy
# dependencies for other packages and are no longer needed.
autoremove

# Clear APT cache
execute \
    "sudo apt-get clean" \
    "APT (clean)"

# Clear thumbnail cache
execute \
    "rm -rf ~/.cache/thumbnails" \
    "Thumbnails cache"
