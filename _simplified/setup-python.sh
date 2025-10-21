#!/bin/bash

# setup-python.sh
# Sets up Python 3 and pip with proper symlinks
# Script must be idempotent!

set -e  # Exit on any error

main() {
    local python3_path
    local pip3_path
    local python_path
    local pip_path
    
    echo "Setting up Python 3 and pip..."
    
    # Check if we're on macOS or Linux
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS - use Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            echo "Error: Homebrew is required but not installed"
            exit 1
        fi
        
        # Install Python 3 if not installed
        if ! command -v python3 >/dev/null 2>&1; then
            echo "Python 3 is not installed. Installing via Homebrew..."
            brew install python
        else
            echo "Python 3 is already installed"
        fi
        
    elif [[ "$(uname -s)" == "Linux" ]]; then
        # Linux - use package manager
        if ! command -v python3 >/dev/null 2>&1; then
            echo "Python 3 is not installed. Installing via package manager..."
            if command -v apt >/dev/null 2>&1; then
                sudo apt update
                sudo apt install -y python3 python3-pip
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y python3 python3-pip
            else
                echo "Error: Unsupported package manager"
                exit 1
            fi
        else
            echo "Python 3 is already installed"
        fi
    else
        echo "Error: Unsupported operating system"
        exit 1
    fi
    
    # Get the path to python3
    python3_path="$(which python3)"
    echo "Python 3 found at: $python3_path"
    
    # Check if pip3 is installed
    if ! command -v pip3 >/dev/null 2>&1; then
        echo "pip3 is not installed. Installing..."
        if [[ "$(uname -s)" == "Darwin" ]]; then
            # On macOS with Homebrew, pip3 should be installed with python3
            echo "pip3 should be installed with Python 3 via Homebrew"
        else
            # On Linux, try to install pip3
            if command -v apt >/dev/null 2>&1; then
                sudo apt install -y python3-pip
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y python3-pip
            fi
        fi
    else
        echo "pip3 is already installed"
    fi
    
    # Get the path to pip3
    pip3_path="$(which pip3)"
    echo "pip3 found at: $pip3_path"
    
    # Determine where to create symlinks
    local bin_dir="/usr/local/bin"
    if [[ ! -w "$bin_dir" ]]; then
        bin_dir="$HOME/.local/bin"
        mkdir -p "$bin_dir"
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
            echo "export PATH=\"$bin_dir:\$PATH\"" >> "$HOME/.bashrc"
            echo "export PATH=\"$bin_dir:\$PATH\"" >> "$HOME/.zshrc" 2>/dev/null || true
        fi
    fi
    
    python_path="$bin_dir/python"
    
    # Check if python command exists and is a symlink to python3
    if command -v python >/dev/null 2>&1; then
        python_path="$(which python)"
        if [[ -L "$python_path" ]]; then
            # It's a symlink, check if it points to python3
            if [[ "$(readlink "$python_path")" == "$python3_path" ]]; then
                echo "python command is already correctly linked to python3"
            else
                echo "python command is a symlink but points to wrong target. Updating..."
                rm "$python_path"
                ln -s "$python3_path" "$python_path"
            fi
        else
            # It's not a symlink, check if it's actually python3
            if [[ "$python_path" == "$python3_path" ]]; then
                echo "python command is already python3"
            else
                echo "python command exists but is not python3. Creating symlink..."
                # Remove the existing python command if it's not python3
                rm "$python_path"
                ln -s "$python3_path" "$python_path"
            fi
        fi
    else
        echo "python command does not exist. Creating symlink to python3..."
        if [[ -L "$python_path" ]]; then
            # Symlink exists, check if it's correct
            if [[ "$(readlink "$python_path")" == "$python3_path" ]]; then
                echo "python symlink already exists and is correct"
            else
                echo "python symlink exists but points to wrong target. Updating..."
                rm "$python_path"
                ln -s "$python3_path" "$python_path"
            fi
        else
            ln -s "$python3_path" "$python_path"
        fi
    fi
    
    pip_path="$bin_dir/pip"
    
    # Check if pip command exists and is a symlink to pip3
    if command -v pip >/dev/null 2>&1; then
        pip_path="$(which pip)"
        if [[ -L "$pip_path" ]]; then
            # It's a symlink, check if it points to pip3
            if [[ "$(readlink "$pip_path")" == "$pip3_path" ]]; then
                echo "pip command is already correctly linked to pip3"
            else
                echo "pip command is a symlink but points to wrong target. Updating..."
                rm "$pip_path"
                ln -s "$pip3_path" "$pip_path"
            fi
        else
            # It's not a symlink, check if it's actually pip3
            if [[ "$pip_path" == "$pip3_path" ]]; then
                echo "pip command is already pip3"
            else
                echo "pip command exists but is not pip3. Creating symlink..."
                # Remove the existing pip command if it's not pip3
                rm "$pip_path"
                ln -s "$pip3_path" "$pip_path"
            fi
        fi
    else
        echo "pip command does not exist. Creating symlink to pip3..."
        if [[ -L "$pip_path" ]]; then
            # Symlink exists, check if it's correct
            if [[ "$(readlink "$pip_path")" == "$pip3_path" ]]; then
                echo "pip symlink already exists and is correct"
            else
                echo "pip symlink exists but points to wrong target. Updating..."
                rm "$pip_path"
                ln -s "$pip3_path" "$pip_path"
            fi
        else
            ln -s "$pip3_path" "$pip_path"
        fi
    fi
    
    # Add bin_dir to current session PATH for verification
    export PATH="$bin_dir:$PATH"
    
    # Verify installation
    echo "Verifying installation..."
    if command -v python >/dev/null 2>&1; then
        python --version
    else
        echo "Warning: python command not found in current PATH"
        echo "Please run: export PATH=\"$bin_dir:\$PATH\""
        echo "Or restart your shell to use the new python and pip commands"
    fi
    
    if command -v pip >/dev/null 2>&1; then
        pip --version
    else
        echo "Warning: pip command not found in current PATH"
        echo "Please run: export PATH=\"$bin_dir:\$PATH\""
        echo "Or restart your shell to use the new python and pip commands"
    fi
    
    echo ""
    echo "Python setup complete!"
    echo "Symlinks created:"
    echo "  $python_path -> $python3_path"
    echo "  $pip_path -> $pip3_path"
    echo ""
    echo "To use the new commands in this session, run:"
    echo "  export PATH=\"$bin_dir:\$PATH\""
    echo ""
    echo "Or restart your shell to automatically use the new commands."
}

main "$@"