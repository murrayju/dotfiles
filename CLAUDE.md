# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository based on Mathias Bynens' dotfiles, providing comprehensive development environment configurations for macOS. The repository uses a modular approach with separate files for different aspects of shell configuration and includes a modern Neovim setup with LSP support.

## Key Commands

### Installation and Setup
```bash
# Fresh installation (clones and runs modern bootstrap)
git clone https://github.com/murrayju/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./bs

# Update existing installation
cd ~/.dotfiles && ./bs

# Install Homebrew packages (includes neovim and modern tools)
./brew.sh

# Configure macOS system preferences (requires admin privileges)
./.macos
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
- **Local customization**: `~/.extra` and `~/.path` for machine-specific settings (not tracked)
- **Cross-platform**: `win/` directory contains Windows-specific configurations

### Key Configuration Files
- `.vimrc` - Comprehensive Vim setup with vim-plug plugin manager
- `.tmux.conf` - Tmux configuration with TPM (Tmux Plugin Manager)
- `.gitconfig` - Git configuration with useful aliases and settings
- `.inputrc` - Readline configuration for better command line editing

### Installation System
- `bootstrap.js` - Modern JavaScript-based installation script using build-strap-cli
- `bs` - Bootstrap entrypoint script from build-strap-cli
- `brew.sh` - Installs essential development tools via Homebrew (includes Neovim)
- `.macos` - Configures macOS system preferences and Finder settings

### Plugin Management
- **Neovim**: Uses lazy.nvim for modern plugin management with LSP support
- **Tmux**: Uses TPM (Tmux Plugin Manager)
- **Zsh**: Configured for Oh My Zsh with Powerlevel10k theme

### Modern Development Features
- **Neovim Configuration**: Complete Lua-based setup in `.config/nvim/`
- **LSP Support**: TypeScript, Go, Ruby, and more language servers
- **GitHub Copilot**: AI-powered code completion
- **Claude Code**: Integration with Claude Code for AI assistance
- **Modern Tools**: ripgrep, fd, exa, bat for enhanced command-line experience

### Customization Pattern
The dotfiles support local customization through:
- `~/.extra` - For commands/settings that shouldn't be in the public repository
- `~/.path` - For additional PATH modifications
- These files are sourced if they exist but not tracked in git