#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_oh_my_bash() {

    local ohMyBashDir="$HOME/.oh-my-bash"
    local bashrcFile="$HOME/.bashrc"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if Oh My Bash is already installed

    if [ -d "$ohMyBashDir" ]; then
        print_success "Oh My Bash is already installed"
        return 0
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Backup existing .bashrc if it exists

    if [ -f "$bashrcFile" ]; then
        execute \
            "cp $bashrcFile ${bashrcFile}.pre-oh-my-bash" \
            "Backup existing .bashrc"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Install Oh My Bash

    execute \
        "bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)\" --unattended" \
        "Install Oh My Bash" \
        || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Verify installation

    if [ ! -d "$ohMyBashDir" ]; then
        print_error "Oh My Bash installation failed"
        return 1
    fi

    print_success "Oh My Bash installed successfully"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

configure_oh_my_bash() {

    local bashrcFile="$HOME/.bashrc"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Check if .bashrc exists

    if [ ! -f "$bashrcFile" ]; then
        print_error ".bashrc not found"
        return 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Set theme to powerline-multiline

    execute \
        "sed -i.bak 's/^OSH_THEME=.*/OSH_THEME=\"powerline-multiline\"/' $bashrcFile" \
        "Set Oh My Bash theme to powerline-multiline" \
        || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Enable plugins: git, docker, npm, extract, common

    execute \
        "sed -i.bak 's/^plugins=.*/plugins=(git docker npm extract common)/' $bashrcFile" \
        "Configure Oh My Bash plugins" \
        || return 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Disable auto-update (manual updates preferred)

    if ! grep -q "DISABLE_AUTO_UPDATE" "$bashrcFile"; then
        execute \
            "echo '' >> $bashrcFile && echo '# Disable automatic updates' >> $bashrcFile && echo 'DISABLE_AUTO_UPDATE=\"true\"' >> $bashrcFile" \
            "Disable Oh My Bash auto-updates"
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Clean up backup files

    rm -f "${bashrcFile}.bak"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

create_custom_directories() {

    local customDir="$HOME/.oh-my-bash/custom"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Create custom directory structure for future use

    execute \
        "mkdir -p $customDir/aliases" \
        "Create custom aliases directory"

    execute \
        "mkdir -p $customDir/functions" \
        "Create custom functions directory"

    execute \
        "mkdir -p $customDir/completions" \
        "Create custom completions directory"

    execute \
        "mkdir -p $customDir/themes" \
        "Create custom themes directory"

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n   Oh My Bash\n\n"

    install_oh_my_bash \
        && configure_oh_my_bash \
        && create_custom_directories

}

main
