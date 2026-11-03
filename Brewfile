# System tools, libraries, and apps. This file is used on macOS and Linux.
# mise installs the developer tools: see dotfiles/.config/mise/config.toml.

brew 'coreutils'

# Install some other useful utilities like `sponge`.
brew 'moreutils'
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew 'findutils'
# Install GNU `sed`, overwriting the built-in `sed`.
brew 'gnu-sed'
# Install a modern version of Bash.
brew 'bash'
brew 'bash-completion@2'
brew 'zsh'

# Install GnuPG to enable PGP-signing commits.
brew 'gnupg'

# Install more recent versions of some macOS tools.
brew 'grep'
brew 'openssh'
brew 'screen'
brew 'php'
brew 'gmp'

# Install font tools.
brew 'woff2'

# Install other useful binaries.
brew 'ack'
brew 'git'
brew 'git-lfs'
brew 'gs'
brew 'imagemagick'
brew 'lua'
brew 'lynx'
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
  # fonts
  cask 'font-fira-code-nerd-font'
  cask 'font-hack-nerd-font'

  # applications
  cask 'visual-studio-code' unless system 'which code'
end
