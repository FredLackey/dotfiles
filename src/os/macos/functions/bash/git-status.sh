#!/bin/bash
# git-status - Show status summary for one or more git repositories
#
# Usage:
#   git-status              # Current repo (or repos under current dir if not in one)
#   git-status /path        # Repo at path, or all repos found under path
#   git-status -d           # Only show repos with changes (dirty)
#   git-status -d /path     # Dirty repos under path
#   git-status -m 3 /path   # Limit search depth to 3 levels
#
# Flags:
#   -d        Dirty only — hide clean repos
#   -m N      Max directory depth for repo discovery (default: unlimited)
#
# Dependencies:
#   - git (brew install git)

git-status() {
    local usage="git-status [-d] [-m depth] [path]"
    local dirty_only=false
    local max_depth=""
    local target_path=""

    # Parse flags
    local args=()
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                echo "git-status — Show status summary for one or more git repositories"
                echo ""
                echo "Usage:"
                echo "  git-status              Scan current repo (or all repos under current dir)"
                echo "  git-status /path        Scan repo at path, or all repos found under path"
                echo "  git-status -d           Only show repos with changes (dirty)"
                echo "  git-status -d /path     Dirty repos under path"
                echo "  git-status -m 3 /path   Limit search depth to 3 levels"
                echo ""
                echo "Flags:"
                echo "  -d          Dirty only — hide clean repos"
                echo "  -m N        Max directory depth for repo discovery (default: unlimited)"
                echo "  -h, --help  Show this help message"
                echo ""
                echo "Legend:"
                echo "  UNSTG   Unstaged modifications"
                echo "  STAGED  Staged changes ready to commit"
                echo "  UNTRK   Untracked files"
                echo "  AHEAD   Commits ahead of remote (needs push)"
                echo "  BEHIND  Commits behind remote (needs pull)"
                echo "  -       No remote tracking branch"
                echo "  .       Zero (clean)"
                return 0
                ;;
            -d) dirty_only=true ;;
            -m) shift; max_depth="$1" ;;
            *)  args+=("$1") ;;
        esac
        shift
    done
    target_path="${args[0]:-}"

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Error: git is required but not installed."
        return 1
    fi

    # If no path provided, detect from current location
    if [ -z "$target_path" ]; then
        local git_root
        git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$git_root" ]; then
            target_path="$git_root"
        else
            target_path="$(pwd)"
        fi
    fi

    # Resolve to absolute path
    if [ ! -d "$target_path" ]; then
        echo "Error: Path does not exist: $target_path"
        return 1
    fi
    target_path=$(cd "$target_path" && pwd)

    # Collect git repos
    local repos=()
    if [ -d "$target_path/.git" ]; then
        repos=("$target_path")
    else
        local find_cmd="find \"$target_path\""
        [ -n "$max_depth" ] && find_cmd="$find_cmd -maxdepth $max_depth"
        find_cmd="$find_cmd -name .git -type d"
        while IFS= read -r gitdir; do
            [ -z "$gitdir" ] && continue
            repos+=("${gitdir%/.git}")
        done < <(eval "$find_cmd" 2>/dev/null | sort)
    fi

    if [ ${#repos[@]} -eq 0 ]; then
        echo "No git repositories found under: $target_path"
        return 0
    fi

    local header_printed=false
    local total_repos=${#repos[@]}
    local clean_repos=0
    local shown_repos=0

    for repo in "${repos[@]}"; do
        # Build display path relative to target
        local rel_path=""
        if [ "$repo" = "$target_path" ]; then
            rel_path="$(basename "$repo")"
        else
            rel_path="${repo#$target_path/}"
        fi

        # Truncate long paths from the left
        if [ ${#rel_path} -gt 50 ]; then
            rel_path="...${rel_path: -47}"
        fi

        # Parse porcelain status for counts
        local unstaged=0 staged=0 untracked=0
        local status_output=""
        status_output=$(git -C "$repo" status --porcelain 2>/dev/null)

        if [ -n "$status_output" ]; then
            while IFS= read -r line; do
                [ -z "$line" ] && continue
                local x="${line:0:1}"
                local y="${line:1:1}"
                if [ "$x" = "?" ]; then
                    ((untracked++))
                else
                    [[ "$x" =~ [MADRC] ]] && ((staged++))
                    [[ "$y" =~ [MADRC] ]] && ((unstaged++))
                fi
            done <<< "$status_output"
        fi

        # Get ahead/behind from upstream tracking
        local ahead="-" behind="-"
        if git -C "$repo" rev-parse --abbrev-ref '@{u}' &>/dev/null; then
            ahead=$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null || echo "0")
            behind=$(git -C "$repo" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo "0")
        fi

        # Determine if repo is clean or dirty
        local c_reset="\033[0m"
        local c=""
        local is_clean=true

        if [ "$unstaged" -gt 0 ] || [ "$staged" -gt 0 ] || [ "$untracked" -gt 0 ]; then
            c="\033[33m"  # Yellow: local changes
            is_clean=false
        elif [ "$ahead" != "-" ] && [ "$ahead" -gt 0 ]; then
            c="\033[36m"  # Cyan: needs push
            is_clean=false
        elif [ "$behind" != "-" ] && [ "$behind" -gt 0 ]; then
            c="\033[35m"  # Magenta: needs pull
            is_clean=false
        else
            c="\033[32m"  # Green: clean
            ((clean_repos++))
        fi

        # Skip clean repos in dirty-only mode
        if [ "$dirty_only" = true ] && [ "$is_clean" = true ]; then
            continue
        fi

        # Print header on first shown repo
        if [ "$header_printed" = false ]; then
            printf "\n"
            printf "  %-50s  %5s  %6s  %5s  %5s  %6s\n" "REPOSITORY" "UNSTG" "STAGED" "UNTRK" "AHEAD" "BEHIND"
            printf "  %-50s  %5s  %6s  %5s  %5s  %6s\n" \
                "──────────────────────────────────────────────────" "─────" "──────" "─────" "─────" "──────"
            header_printed=true
        fi
        ((shown_repos++))

        # Format numeric zeros as dots for readability
        local d_unstaged="." d_staged="." d_untracked="." d_ahead="." d_behind="."
        [ "$unstaged" -gt 0 ] && d_unstaged="$unstaged"
        [ "$staged" -gt 0 ] && d_staged="$staged"
        [ "$untracked" -gt 0 ] && d_untracked="$untracked"
        [ "$ahead" != "-" ] && [ "$ahead" != "0" ] && d_ahead="$ahead"
        [ "$ahead" = "-" ] && d_ahead="-"
        [ "$behind" != "-" ] && [ "$behind" != "0" ] && d_behind="$behind"
        [ "$behind" = "-" ] && d_behind="-"

        printf "  ${c}%-50s  %5s  %6s  %5s  %5s  %6s${c_reset}\n" \
            "$rel_path" "$d_unstaged" "$d_staged" "$d_untracked" "$d_ahead" "$d_behind"
    done

    # Summary and legend
    printf "\n"
    if [ "$dirty_only" = true ]; then
        printf "  %d repos scanned, %d dirty, %d clean (hidden)\n" "$total_repos" "$shown_repos" "$clean_repos"
    else
        printf "  %d repos scanned, %d clean\n" "$total_repos" "$clean_repos"
    fi
    printf "  \033[32m*\033[0m Clean  \033[33m*\033[0m Local changes  \033[36m*\033[0m Needs push  \033[35m*\033[0m Needs pull  \033[0m-\033[0m No remote\n"
    printf "\n"
}
