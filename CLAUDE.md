# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository based on Mathias Bynens' dotfiles, providing comprehensive development environment configurations for macOS and Linux. The repository uses a modular approach with separate files for different aspects of shell configuration, an OS overlay for each shared file, and includes a modern Neovim setup with LSP support.

## Key Commands

### Installation and Setup
```bash
# Fresh installation (clones and runs modern bootstrap)
git clone https://github.com/murrayju/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./bs

# Update existing installation (also installs the Brewfile and mise tools)
cd ~/.dotfiles && ./bs

# Linux only: install the distro packages the dotfiles rely on (needs sudo)
cd ~/.dotfiles && ./bs apt

# Install or re-check pi (the bootstrap does this too)
cd ~/.dotfiles && ./bs pi

# Configure macOS system preferences (requires admin privileges)
./macos.sh
```

### Development
```bash
# Reload shell configuration
reload

# Update all package managers
update

# List all aliases
alias
```

## Architecture and Structure

### Core Configuration System
- **Main shell files**: `.bash_profile`, `.zshrc` handle shell initialization
- **Modular components**: `.aliases`, `.functions`, `.exports` provide specific functionality
- **OS overlays**: `.aliases_darwin`/`.aliases_linux`, `.functions_darwin`/`.functions_linux`, `.exports_darwin`/`.exports_linux` are sourced right after their shared counterpart, based on `$OSTYPE`. Anything platform-specific (Finder/`defaults`/`pbcopy` on macOS, `ip`/`loginctl`/bwrap on Linux) goes in the overlay, never in the shared file.
- **Local customization**: `~/.extra` and `~/.path` for machine-specific settings (not tracked)
- **Cross-platform**: `win/` directory contains Windows-specific configurations

### Key Configuration Files
- `.vimrc` - Comprehensive Vim setup with vim-plug plugin manager
- `.tmux.conf` - Tmux configuration with TPM (Tmux Plugin Manager)
- `.gitconfig` - Git configuration with useful aliases and settings
- `.inputrc` - Readline configuration for better command line editing

### Installation System
- `targets/bootstrap.ts` - Modern JavaScript-based installation script using build-strap-cli
- `targets/apt.ts` - `./bs apt`; installs `packages/apt.txt` via apt-get (Linux only, opt-in, needs sudo)
- `targets/pi.ts` - `./bs pi`; installs pi from https://pi.dev/install.sh when missing. The installer is interactive, so it is spawned `detached` (no controlling terminal) to make it take its default action without prompting; node/npm come from the mise shims.
- `bs` - Bootstrap entrypoint script from build-strap-cli
- `Brewfile` - System tools, libraries, and apps via Homebrew, with `if OS.mac?` / `if OS.linux?` blocks. On Linux it intentionally avoids anything that would shadow distro tools or system services.
- `packages/apt.txt` - Debian/Ubuntu packages (gnupg, openssh-client, bash-completion, bubblewrap, …)
- `dotfiles/.config/mise/config.toml` - Global developer tools via mise (Node, Go, Neovim, ripgrep, and more)
- `macos.sh` - Configures macOS system preferences and Finder settings

### PATH precedence
macOS prepends Homebrew to `$PATH`; Linux **appends** it (see the brew block in `.bash_profile`/`.zshrc`) so `gpg`, `ssh`, `python3`, `curl`, `sed`, `grep` and the dbus/glib tools keep resolving to the distro's copies. mise activates last. Changing this ordering is what caused the gpg-agent/commit-signing breakage on Linux — don't "fix" it back to `brew shellenv`-only.

### Package manager split
- Homebrew: fonts/apps and macOS-only GNU userland
- apt (`./bs apt`): anything with system integration on Linux
- mise: language runtimes and dev CLIs (never duplicate these in the Brewfile)

### Plugin Management
- **Neovim**: Uses lazy.nvim for modern plugin management with LSP support
- **Tmux**: Uses TPM (Tmux Plugin Manager)
- **Zsh**: Configured for Oh My Zsh with Powerlevel10k theme

### Modern Development Features
- **Neovim Configuration**: Complete Lua-based setup in `.config/nvim/`
- **LSP Support**: TypeScript, Go, Ruby, and more language servers
- **GitHub Copilot**: AI-powered code completion
- **Claude Code**: Integration with Claude Code for AI assistance
- **Modern Tools**: ripgrep, fd, eza, bat for enhanced command-line experience

### Customization Pattern
The dotfiles support local customization through:
- `~/.extra` - For commands/settings that shouldn't be in the public repository
- `~/.path` - For additional PATH modifications
- These files are sourced if they exist but not tracked in git