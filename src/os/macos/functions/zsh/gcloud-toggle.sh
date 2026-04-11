#!/bin/zsh
# gcloud-toggle - Cycle the active gcloud account to the next credentialed one
#
# Lists all accounts that gcloud has credentials for, finds the currently
# active one, and switches to the next account in the list (wrapping around).
# If the current account is not found in the list (e.g. it was revoked),
# falls back to the first account.
#
# Usage:
#   gcloud-toggle
#
# Dependencies:
#   - gcloud (brew install --cask google-cloud-sdk)

gcloud-toggle() {
    if ! command -v gcloud &> /dev/null; then
        echo "gcloud-toggle: gcloud is not installed" >&2
        return 1
    fi

    local -a accounts
    accounts=("${(@f)$(gcloud auth list --format='value(account)' 2>/dev/null)}")

    # Drop any empty entries that can appear when no accounts are credentialed
    accounts=(${accounts:#})

    if (( ${#accounts[@]} == 0 )); then
        echo "gcloud-toggle: no credentialed accounts found" >&2
        echo "  run: gcloud auth login" >&2
        return 1
    fi

    if (( ${#accounts[@]} == 1 )); then
        echo "gcloud-toggle: only one account (${accounts[1]}); nothing to toggle" >&2
        return 0
    fi

    local current next idx
    current=$(gcloud config get-value account 2>/dev/null)

    # zsh arrays are 1-indexed; (ie) returns length+1 when the value is not found
    idx=${accounts[(ie)$current]}
    if (( idx > ${#accounts[@]} )); then
        next=${accounts[1]}
    else
        next=${accounts[$(( idx % ${#accounts[@]} + 1 ))]}
    fi

    if gcloud config set account "$next" >/dev/null 2>&1; then
        echo "gcloud: ${current:-<none>} → $next"
    else
        echo "gcloud-toggle: failed to switch account to $next" >&2
        return 1
    fi
}
