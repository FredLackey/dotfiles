#!/bin/bash

# Install essential packages using Homebrew
# This script installs various development tools and applications

main() {
    echo "Installing Homebrew packages..."

    # Bash and shell tools
    # brew install bash
    # brew install bash-completion@2
    # brew install shellcheck

    # Git
    brew install git

    # Browsers
    brew install --cask google-chrome
    brew install --cask google-chrome@canary
    # brew install --cask safari-technology-preview

    # Development tools
    brew install vim
    brew install tmux
    brew install reattach-to-user-namespace
    brew install go
    brew install awscli
    brew install lftp
    brew install tailscale
    brew install tfenv
    brew install yt-dlp
    brew install neovim

    # GPG
    brew install gpg
    # brew install pinentry-mac

    # Image tools
    # brew install --cask imageoptim
    # brew install --cask pngyu

    # Video tools
    # brew install atomicparsley
    # brew install ffmpeg

    # Web font tools
    # brew install sfnt2woff-zopfli --tap bramstein/webfonttools
    # brew install sfnt2woff --tap bramstein/webfonttools
    # brew install woff2 --tap bramstein/webfonttools

    # Miscellaneous utilities
    brew install --cask vlc
    brew install jq
    brew install yq
    brew install --cask logitune
    brew install --cask moom
    brew install --cask iterm2

    # Applications
    brew install --cask adobe-creative-cloud
    brew install --cask appcleaner
    brew install --cask bambu-studio
    brew install --cask balenaetcher
    brew install --cask beyond-compare
    brew install --cask caffeine
    brew install --cask camtasia
    brew install --cask chatgpt
    brew install --cask cursor
    brew install --cask dbschema
    brew install --cask docker
    brew install --cask drawio
    brew install --cask elmedia-player
    # brew install --cask keyboard-maestro
    # brew install --cask messenger
    brew install --cask microsoft-office
    brew install --cask microsoft-teams
    # brew install --cask mysqlworkbench
    # brew install --cask nordpass
    # brew install postman
    
    # brew install --cask skype
    brew install --cask slack
    brew install --cask snagit
    brew install --cask spotify
    brew install --cask studio-3t
    brew install sublime-text
    brew install --cask superwhisper
    brew install --cask termius
    # brew install --cask tidal
    brew install --cask visual-studio-code
    brew install --cask whatsapp
    brew install --cask zoom

    # LazyGit
    brew install lazygit

    # AI Tools
    brew install --cask claude-code

    # Yarn (if nvm is installed)
    if [ -d "$HOME/.nvm" ]; then
        brew install yarn
    fi

    echo "Homebrew packages installation completed!"
}

main
