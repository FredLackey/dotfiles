#!/bin/bash

# set-zsh.sh
# Sets up Zsh as the default shell.  Installs ZSH if needed.
# Script must be idempotent!

set -e  # Exit on any error

main() {

  # Is ZSH installed?
  if ! command -v zsh >/dev/null 2>&1; then
    echo "ZSH is not installed.  Installing..."

    # Is the OS Ubuntu or MacOS?
    if [ "$(uname -s)" == "Darwin" ]; then
      brew install zsh
    elif [ "$(uname -s)" == "Linux" ]; then
      sudo apt install zsh
    fi

  fi
  
  # Is ZSH the default shell?
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "ZSH is not the default shell.  Setting as default..."
    chsh -s "$(which zsh)"
  fi

  # Am I in the correct shell?
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "I am not in the correct shell.  Setting as default..."
    exec zsh
  fi

  # Install the Powerline fonts
  pip install --user powerline-status

  # Is Oh My Zsh installed?
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed.  Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  
  # Is Powerlevel10k installed?
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo "Powerlevel10k is not installed.  Installing..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  fi
  
  # Set the theme in ~/.zshrc
  echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc
  echo "source $HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
  
  # Restart the shell
  echo "Restarting the shell..."
  exec zsh

  echo "ZSH setup complete!"
  

}

main "$@"