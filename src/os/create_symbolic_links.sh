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
    local baseDir="$(cd .. && pwd)"

    # Helper function to get the correct source path for shell files.
    # Uses OS-specific file if it exists, otherwise falls back to base shell/.
    # Exception: Files that internally source their OS-specific variants
    # (via `. "$OS/filename"`) must always use the base file.
    get_shell_source() {
        local filename="$1"

        # These files source OS-specific variants internally via `. "$OS/filename"`
        # and must always symlink to the base file to avoid bypassing common config.
        local -a self_sourcing_files=(
            "bash_aliases"
            "bash_autocompletion"
            "bash_init"
        )

        for f in "${self_sourcing_files[@]}"; do
            if [ "$filename" = "$f" ]; then
                printf "%s" "shell/$filename"
                return
            fi
        done

        if [ -f "$baseDir/shell/$os_name/$filename" ]; then
            printf "%s" "shell/$os_name/$filename"
        else
            printf "%s" "shell/$filename"
        fi
    }

    declare -a FILES_TO_SYMLINK=(

        "$(get_shell_source 'bash_aliases')"
        "$(get_shell_source 'bash_autocompletion')"
        "$(get_shell_source 'bash_exports')"
        "$(get_shell_source 'bash_functions')"
        "$(get_shell_source 'bash_init')"
        "$(get_shell_source 'bash_logout')"
        "$(get_shell_source 'bash_options')"
        "$(get_shell_source 'bash_profile')"
        "$(get_shell_source 'bash_prompt')"
        "$(get_shell_source 'bashrc')"
        "shell/curlrc"
        "shell/inputrc"

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

        sourceFile="$baseDir/$i"
        targetFile="$HOME/.$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

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
