#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

backup_bash_files() {
    find "$HOME" -maxdepth 1 -name ".bash*" -type f | while IFS= read -r file; do
        # Skip files that are already backups (end with -original)
        if [[ "$file" == *-original* ]]; then
            continue
        fi

        # Only create backup if it doesn't already exist
        if [ -e "${file}-original" ]; then
            print_success "Backup of ${file} already exists (preserved)"
        else
            execute "cp $file ${file}-original" "Backup $file"
        fi
    done
}

create_symlinks() {

    local os_name="$(get_os_name)"
    local shell_path="shell"

    # Use OS-specific shell files if they exist
    if [ -d "../shell/$os_name" ]; then
        shell_path="shell/$os_name"
    fi

    declare -a FILES_TO_SYMLINK=(

        "$shell_path/bash_aliases"
        "$shell_path/bash_autocompletion"
        "$shell_path/bash_exports"
        "$shell_path/bash_functions"
        "$shell_path/bash_init"
        "$shell_path/bash_logout"
        "$shell_path/bash_options"
        "$shell_path/bash_profile"
        "$shell_path/bash_prompt"
        "$shell_path/bashrc"
        "shell/curlrc"
        "shell/inputrc"

        # Always symlink the main bash_functions for OS-specific files to source
        "shell/bash_functions:bash_functions_main"

        "git/gitattributes"
        "git/gitconfig"
        "git/gitignore"

        "tmux/tmux.conf"

        "vim/vim"
        "vim/vimrc"

    )

    local i=""
    local sourceFile=""
    local targetFile=""
    local skipQuestions=false

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    for i in "${FILES_TO_SYMLINK[@]}"; do

        # Check if entry has custom target name (format: source:target)
        if [[ "$i" == *:* ]]; then
            local sourcePath="${i%%:*}"
            local targetName="${i##*:}"
            sourceFile="$(cd .. && pwd)/$sourcePath"
            targetFile="$HOME/.$targetName"
        else
            sourceFile="$(cd .. && pwd)/$i"
            targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"
        fi

        if [ ! -e "$targetFile" ] || $skipQuestions; then

            execute \
                "ln -fs $sourceFile $targetFile" \
                "$targetFile → $sourceFile"

        elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
            print_success "$targetFile → $sourceFile"
        else

            if ! $skipQuestions; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then

                    rm -rf "$targetFile"

                    execute \
                        "ln -fs $sourceFile $targetFile" \
                        "$targetFile → $sourceFile"

                else
                    print_error "$targetFile → $sourceFile"
                fi

            fi

        fi

    done

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {

    print_in_purple "\n • Backup Original Bash Files\n\n"
    backup_bash_files "$@"

    print_in_purple "\n • Create symbolic links\n\n"
    create_symlinks "$@"

}

main "$@"
