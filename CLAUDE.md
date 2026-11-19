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

# Install or update the Pi Herdr subagents extension (the bootstrap does this too)
cd ~/.dotfiles && ./bs pi-herdr-subagents

# Install or re-check the Concentrate CLI (`cn`; the bootstrap does this too)
cd ~/.dotfiles && ./bs concentrate

# Ask for the Concentrate AI API key when cn has none saved (the bootstrap does this too)
cd ~/.dotfiles && ./bs concentrate-key

# Connect pi to Concentrate with `cn configure pi` when cn has a saved key (the bootstrap does this too)
cd ~/.dotfiles && ./bs concentrate-configure

# Install the Pi catalog pruner and refresh the model list (the bootstrap does this too)
cd ~/.dotfiles && ./bs concentrate-prune

# Apply the tracked pi preferences (the bootstrap does this too)
cd ~/.dotfiles && ./bs pi-settings

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
- `targets/bootstrap.ts` - Installation script, TypeScript run directly by Bun
- `targets/apt.ts` - `./bs apt`; installs `packages/apt.txt` via apt-get (Linux only, opt-in, needs sudo)
- `targets/pi.ts` - `./bs pi`; installs pi from https://pi.dev/install.sh when missing. The installer is interactive, so it is spawned `detached` (no controlling terminal) to make it take its default action without prompting; node/npm come from the mise shims.
- `targets/skills.ts` - `./bs skills`; clones https://github.com/murrayju/skills into `~/.agents/skills`, the Agent Skills directory pi discovers, when it is missing, and otherwise fast-forwards it with `git pull --ff-only origin main`. Updating is best-effort: an offline machine, local commits, a diverged history, a branch other than `main`, or a directory that is not that clone only warns, so the rest of the bootstrap still runs. Git runs with `GIT_TERMINAL_PROMPT=0` and `ssh -o BatchMode=yes` (unless `GIT_SSH_COMMAND` or `core.sshCommand` is set), so a missing key cannot make the bootstrap wait on a prompt. Other tools install skills in the same directory (the repository's `.gitignore` hides them from the clone) and this step leaves them alone, so a directory those tools create before the first bootstrap is warned about, not replaced. The bootstrap does this after installing pi.
- `targets/pi-herdr-subagents.ts` - `./bs pi-herdr-subagents`; clones https://github.com/murrayju/pi-herdr-subagents into `~/.pi/agent/extensions/herdr-subagents`, or under `PI_CODING_AGENT_DIR` if set. It shares `targets/git-checkout.ts` with the skills target: clone or fast-forward `main`, warn on failure, and leave unrelated directories alone. Pi discovers the clone automatically, so do not add a second copy through Pi's package settings.
- `targets/concentrate.ts` - `./bs concentrate`; installs the Concentrate CLI (`cn`) from https://github.com/concentrateai-hq/cli when missing. Uses the same non-interactive `detached` install as pi, and only needs Node.js 22.13+ (from the mise shims).
- `targets/concentrate-prune.ts` - `./bs concentrate-prune`; copies `bin/pi-concentrate-prune` to `~/bin`, runs `cn refresh`, then prunes the Pi catalog to the newest model of each chosen line. The bootstrap does this after installing pi and `cn`.
- `targets/concentrate-key.ts` - `./bs concentrate-key`; asks for the Concentrate AI API key with `cn key` when cn has none saved. `cn key` hides the input, checks the key against the API, and writes cn's own `credentials.json` with mode 600, so the key never enters this repository or the bootstrap process. The step skips itself when a key is saved, when `CONCENTRATE_API_KEY` is set, or when stdin is not a terminal. The bootstrap does this after installing `cn` and before `pi-settings`.
- `targets/concentrate-configure.ts` - `./bs concentrate-configure`; runs `cn configure pi` to write pi's Concentrate provider into `~/.pi/agent/models.json` and to point pi's defaults at Concentrate. It skips when Pi already has an active cn setup, because `cn refresh` in the prune step updates that setup, and `cn configure pi` refuses a settings file that was edited after the last configure. It also skips when cn has no saved key, because cn needs a stored key for a permanent setup, and when `pi` or `cn` is missing. A skipped run is not a problem: run `cn configure pi` by hand if cn has a stale setup record. The step puts the directory of the pi launcher first on `PATH` for the command, since the bootstrap does not load the shell profile. The bootstrap does this after the key step and before `pi-settings`, because `cn configure pi` writes its own default model and `pi-settings` then applies the managed one.
- `pi/settings.json` - the tracked pi preferences: `defaultProvider`, `defaultModel`, `defaultThinkingLevel`, `enabledModels`, `showHardwareCursor`, and `packages`.
- `targets/pi-settings.ts` - `./bs pi-settings`; merges the keys in `pi/settings.json` into `~/.pi/agent/settings.json` and leaves every other key alone, so pi's `lastChangelogVersion` and `extensionChangelogVersions` survive. A managed key changed inside pi is overwritten on the next bootstrap. `packages` is a union, so removing an entry from `pi/settings.json` does not uninstall it; `enabledModels` replaces the list. It also sets cn's default Pi model (`cn model pi <id>`) and records the value in cn's restore record, because `cn refresh` refuses a Pi settings file whose default model differs from what it wrote. It sets the cn model before it merges the settings, because `cn model pi` reconfigures Pi itself and cn rejects a settings file that already differs from its record. The bootstrap runs it after `concentrate-configure` and before the refresh/prune step. Update `pi/settings.json` when the pruner drops a model because a line moved to a new version.
- `targets/install-script.ts` - shared `runInstaller` helper: runs a `curl … | <shell>` installer `detached` with the mise shims on `PATH`, so installers never prompt and find node/npm from mise.
- `bun` - Pinned [bun-strap](https://github.com/murrayju/bun-strap) launcher; downloads Bun into `download/bun/<version>` on first use, so no global runtime is required. Bump the version inside it deliberately.
- `bs` - Bootstrap entrypoint: `./bun install` then `./bun ./targets/run.ts "$@"` (run from anywhere; it cds to the repo first)
- `package.json` / `bun.lock` - Build tooling dependencies (`build-strap`, `fs-extra`, `typescript`, `prettier`); `bun.lock` is committed
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
- bun (via `./bun`): the dotfiles' own build tooling only; never a prerequisite, since bun-strap downloads it

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