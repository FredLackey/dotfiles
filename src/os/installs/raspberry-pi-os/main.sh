#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

update
upgrade

./build-essentials.sh

./git.sh
./../nvm.sh
./browsers.sh
./compression_tools.sh
./image_tools.sh
./misc.sh
./misc_tools.sh
./go.sh
./../gitego.sh
./docker.sh
./../npm.sh
./tmux.sh
./vim.sh
./claude-code.sh

./cleanup.sh
