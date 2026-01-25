#!/bin/bash
# Run tests for all Docker environments
#
# Usage:
#   ./test-all.sh [options]
#
# Options:
#   --local         - Mount local dotfiles instead of downloading from GitHub
#   --branch <name> - Use specific GitHub branch (default: main)
#   --stop-on-fail  - Stop testing after first failure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
LOCAL_MODE=false
BRANCH="main"
STOP_ON_FAIL=false

# Parse arguments
PASSTHROUGH_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --local)
            LOCAL_MODE=true
            PASSTHROUGH_ARGS+=("--local")
            shift
            ;;
        --branch)
            BRANCH="$2"
            PASSTHROUGH_ARGS+=("--branch" "$2")
            shift 2
            ;;
        --stop-on-fail)
            STOP_ON_FAIL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

ENVIRONMENTS=("ubuntu-server" "ubuntu-desktop" "ubuntu-wsl")

echo "========================================"
echo "Running All Tests"
echo "========================================"
echo "Mode: $([ "$LOCAL_MODE" = true ] && echo "Local" || echo "Remote (branch: $BRANCH)")"
echo "Stop on fail: $STOP_ON_FAIL"
echo "Environments: ${ENVIRONMENTS[*]}"
echo "========================================"
echo ""

# Track results
declare -A RESULTS
FAILED=0
PASSED=0

for ENV in "${ENVIRONMENTS[@]}"; do
    echo ""
    echo "########################################"
    echo "# Testing: $ENV"
    echo "########################################"
    echo ""

    if "$SCRIPT_DIR/test.sh" "$ENV" "${PASSTHROUGH_ARGS[@]}"; then
        RESULTS[$ENV]="PASSED"
        ((PASSED++))
    else
        RESULTS[$ENV]="FAILED"
        ((FAILED++))

        if [ "$STOP_ON_FAIL" = true ]; then
            echo ""
            echo "Stopping due to --stop-on-fail"
            break
        fi
    fi
done

# Print summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
for ENV in "${ENVIRONMENTS[@]}"; do
    RESULT="${RESULTS[$ENV]:-SKIPPED}"
    if [ "$RESULT" = "PASSED" ]; then
        echo "  $ENV: PASSED"
    elif [ "$RESULT" = "FAILED" ]; then
        echo "  $ENV: FAILED"
    else
        echo "  $ENV: SKIPPED"
    fi
done
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "========================================"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
