#!/bin/bash

# import.sh
# Imports all .terminal files for macOS Terminal and sets Solarized Dark as default
# Script must be idempotent!

set -e  # Exit on any error

main() {
  local script_dir
  local applescript_file
  
  # Get the directory where this script is located
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  applescript_file="$script_dir/import_themes.applescript"
  
  echo "Importing terminal themes from: $script_dir"
  
  # Check if we're on macOS
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS only"
    exit 1
  fi
  
  # Check if AppleScript file exists
  if [[ ! -f "$applescript_file" ]]; then
    echo "Error: AppleScript file not found: $applescript_file"
    exit 1
  fi
  
  # Remove quarantine attributes from terminal files and AppleScript
  echo "Removing quarantine attributes..."
  xattr -d com.apple.quarantine "$script_dir"/*.terminal 2>/dev/null || true
  xattr -d com.apple.quarantine "$applescript_file" 2>/dev/null || true
  
  # Check if Terminal app is available
  if ! osascript -e 'tell application "System Events" to get name of every process' | grep -q "Terminal"; then
    echo "Terminal app is not running. Starting Terminal..."
    open -a Terminal
    sleep 2
  fi
  
  # Execute the AppleScript with the script directory as parameter
  echo "Running AppleScript to import themes and set default..."
  osascript "$applescript_file" "$script_dir"
  
  echo "Terminal theme import complete!"
}

main "$@"