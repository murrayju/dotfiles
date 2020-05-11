#!/usr/bin/env bash

# Make sure that brew is installed
brew --version || $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
# Install a modern version of Bash.
brew install bash
brew install bash-completion2
brew install fish
brew install zsh

# Make sure that shells are available
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
fi;
if ! fgrep -q "${BREW_PREFIX}/bin/fish" /etc/shells; then
  echo "${BREW_PREFIX}/bin/fish" | sudo tee -a /etc/shells;
fi;
if ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells; then
  echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells;
	# Use fish as default
	chsh -s "${BREW_PREFIX}/bin/fish"
fi;

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install openssh
brew install screen
brew install php
brew install gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install woff2

# fonts
brew tap homebrew/cask-fonts
brew cask install font-firamono-nerd-font
brew cask install font-hack-nerd-font

# Install other useful binaries.
brew install ack
brew install bat
brew install git
brew install git-lfs
brew install gs
brew install imagemagick
brew install lua
brew install lynx
brew install node
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install starship
brew install tree
brew install vbindiff
brew install wget
brew install zopfli

# applications
brew cask install visual-studio-code

# Remove outdated versions from the cellar.
brew cleanup
