#!/bin/bash
# Create a zip backup of a git repository.
#
# Usage:
#   git-backup /path/to/target/folder
#   git-backup /path/to/target/folder git@github.com:user/repo.git

git-backup() {
    local target_folder="$1"
    local ssh_repo="$2"
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M")

    if [[ -z "$target_folder" ]]; then
        echo "Usage: git-backup <target-folder> [ssh-repo]"
        return 1
    fi

    mkdir -p "$target_folder"

    local workdir repo_name archive_name repo_path

    if [[ -n "$ssh_repo" ]]; then
        workdir=$(mktemp -d)
        git clone --mirror "$ssh_repo" "$workdir/mirror" > /dev/null 2>&1
        repo_name=$(basename -s .git "$ssh_repo")
        repo_path="$workdir/mirror"
    else
        if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
            echo "Error: not inside a Git repository."
            return 1
        fi
        repo_path=$(git rev-parse --show-toplevel)
        repo_name=$(basename "$repo_path")
        workdir=$(mktemp -d)
        git clone --mirror "$repo_path" "$workdir/mirror" > /dev/null 2>&1
    fi

    archive_name="${repo_name}-${timestamp}.zip"
    archive_path="${target_folder}/${archive_name}"

    # Create wrapper directory and move mirror there
    wrapper_dir="${workdir}/wrapper"
    mkdir -p "$wrapper_dir"
    mv "$workdir/mirror" "$wrapper_dir/${repo_name}.git"

    # Create README.md
    cat > "$wrapper_dir/README.md" <<EOF
# ${repo_name} Backup

This is a mirror clone of the Git repository, created on ${timestamp}.

## Usage

To clone this backup and preserve all refs and history, run:

    git clone --mirror ${repo_name}.git

To clone it and create a working directory:

    git clone ${repo_name}.git ${repo_name}-restored

EOF

    # Check for existing backups
    latest_backup=$(ls -t "$target_folder"/${repo_name}-*.zip 2>/dev/null | head -n 1)
    if [[ -n "$latest_backup" ]]; then
        temp_extract=$(mktemp -d)
        unzip -qq "$latest_backup" -d "$temp_extract"

        old_hash=$(cd "$temp_extract"/* && git rev-parse HEAD 2>/dev/null)
        new_hash=$(cd "$wrapper_dir/${repo_name}.git" && git rev-parse HEAD 2>/dev/null)

        if [[ "$old_hash" == "$new_hash" && -n "$old_hash" ]]; then
            echo "No changes since last backup. Skipping new archive."
            rm -rf "$temp_extract" "$workdir"
            return 0
        fi
        rm -rf "$temp_extract"
    fi

    (cd "$wrapper_dir" && zip -qr "$archive_path" .)
    echo "Backup created at: $archive_path"

    rm -rf "$workdir"
}
