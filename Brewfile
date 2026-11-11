# System tools, libraries, and apps.
# mise installs the developer tools: see dotfiles/.config/mise/config.toml.
#
# A Brewfile is a Ruby DSL, so OS-specific entries live in the OS blocks below.
# `brew bundle --file Brewfile` works on either OS.
#
# On Linux, Homebrew lives *after* the distro tools in $PATH (see
# .bash_profile/.zshrc), and anything with system integration (gpg, ssh, git,
# python, curl, openssl, dbus/glib, sed, grep, findutils, coreutils) must come
# from the distro. Those are installed by `./bs apt` from packages/apt.txt.

brew 'ack'
brew 'imagemagick'
brew 'lynx'
brew 'moreutils'
brew 'p7zip'
brew 'pigz'
brew 'pv'
brew 'rename'
brew 'rlwrap'
brew 'ssh-copy-id'
brew 'tree'
brew 'vbindiff'
brew 'wget'
brew 'zopfli'

if OS.mac?
  # Recent versions of the tools macOS ships ancient copies of, plus the GNU
  # userland the shell config prefers.
  brew 'coreutils'
  brew 'findutils'
  brew 'gnu-sed'
  brew 'grep'
  brew 'bash'
  brew 'bash-completion@2'
  brew 'zsh'
  brew 'openssh'
  brew 'screen'
  brew 'php'
  brew 'gmp'
  brew 'woff2'
  brew 'lua'
  brew 'gs'

  # GnuPG to enable PGP-signing commits; macOS ships none.
  brew 'gnupg'
  brew 'git'
  brew 'git-lfs'

  # fonts
  cask 'font-fira-code-nerd-font'
  cask 'font-hack-nerd-font'

  # applications
  cask 'visual-studio-code' unless system 'which code'
end

if OS.linux?
  # Deliberately minimal: no distro duplicates, and nothing that would shadow a
  # system service from Homebrew's bin directory. Distro packages that the
  # dotfiles need come from `./bs apt`.
  cask 'font-fira-code-nerd-font'
  cask 'font-hack-nerd-font'
end
