# Justin’s dotfiles

![Screenshot of my shell prompt](https://i.imgur.com/EkEtphC.png)

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Using Git and the modern bootstrap system

You can clone the repository wherever you want (I like to keep it in `~/.dotfiles`). The modern bootstrapper is TypeScript run by [Bun](https://bun.sh); `./bs` fetches a pinned Bun with [bun-strap](https://github.com/murrayju/bun-strap), so nothing has to be installed globally. It then installs dependencies, creates symlinks, and backs up existing files.

#### macOS/Linux

```bash
git clone https://github.com/murrayju/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./bs
```

To update, just run the bootstrap script again

```bash
cd ~/.dotfiles && ./bs
```

The new bootstrap system will:

- Download a pinned Bun into `download/bun/` using bun-strap (no global Node.js, Bun, or package manager needed)
- Create symlinks from the repository to your home directory
- Back up any existing files that differ from the repository versions
- Install Oh My Zsh, Powerlevel10k theme, and Tmux Plugin Manager
- Install [Homebrew](https://brew.sh/) and the formulae in `Brewfile` (macOS and Linux)
- Install [mise](https://mise.jdx.dev/) and the tools in `dotfiles/.config/mise/config.toml`
- Install [pi](https://pi.dev/) if it is not already installed
- Clone [murrayju/skills](https://github.com/murrayju/skills) into `~/.agents/skills` and fast-forward it to latest `main`
- Clone [pi-herdr-subagents](https://github.com/murrayju/pi-herdr-subagents) into Pi's global extensions and fast-forward it to latest `main`
- Install the [Concentrate CLI](https://github.com/concentrateai-hq/cli) (`cn`) if it is not already installed
- Ask for the Concentrate AI API key when `cn` has none saved (answer `n` to skip)
- Apply the tracked [pi](https://pi.dev/) preferences (default model, thinking level, enabled models, hardware cursor, and packages)
- Install the Pi catalog pruner and refresh the Concentrate model list
- Set up the modern Neovim configuration

On Linux the bootstrap does **not** install distro packages. Do that once, separately (it needs sudo):

```bash
cd ~/.dotfiles && ./bs apt
```

The pi installer is normally interactive; the bootstrap runs it without a controlling terminal, which makes it take its default action and install noninteractively. Re-run it on its own with `./bs pi`. The shell config puts `~/.pi/agent/bin` on `$PATH`, so a freshly installed pi is usable after `reload`.

The Concentrate CLI is installed the same way (noninteractively) with `./bs concentrate`. It needs Node.js 22.13+, which mise provides, and puts its `cn` launcher in `~/.local/bin`, which the shell config already puts on `$PATH`.

The API key is the one thing the dotfiles cannot carry, so the bootstrap asks for it. `./bs concentrate-key` runs `cn key` when cn has no saved key: cn prompts with hidden input, checks the key against the API, and writes it to its own config directory with mode 600. The repository and the bootstrap process never hold the key. Answer `n` at the question to skip, or set `CONCENTRATE_API_KEY` in `~/.extra` and cn uses that key instead. When stdin is not a terminal the step skips itself, so a non-interactive bootstrap never waits for an answer.

Each bootstrap also installs `bin/pi-concentrate-prune` to `~/bin` and runs `cn refresh`. Refresh writes the full catalog, and the pruner keeps the newest model of each chosen line. Run that step on its own with `./bs concentrate-prune`.

### pi preferences

`pi/settings.json` holds the pi preferences the bootstrap manages: `defaultProvider`, `defaultModel`, `defaultThinkingLevel`, `enabledModels`, `showHardwareCursor`, and `packages` (which includes [pi-advisor-flow](https://www.npmjs.com/package/pi-advisor-flow)).

That file is merged into `~/.pi/agent/settings.json` rather than symlinked, because pi also keeps its own state there: `lastChangelogVersion`, `extensionChangelogVersions`, the theme, and anything you change inside pi. Only the listed keys are written, so the other keys survive. A listed key changed inside pi is put back on the next bootstrap. `enabledModels` replaces the current list, and `packages` is a union so other installed packages stay; removing an entry from `pi/settings.json` does not uninstall the package. Run the step on its own with `./bs pi-settings`.

`cn` owns the same two default-model keys and refuses to refresh a tool whose settings differ from what it wrote. So the step also sets cn's default Pi model (`cn model pi <id>`) and records the value in cn's restore record, which keeps `cn refresh` working after a bootstrap.

### Pi subagents in Herdr

[pi-herdr-subagents](https://github.com/murrayju/pi-herdr-subagents) runs Pi workers in named Herdr tabs and shows their output and usage in the parent session. Bootstrap clones it into `~/.pi/agent/extensions/herdr-subagents` (or under `$PI_CODING_AGENT_DIR`) and only pulls fast-forward updates on `main`. Use `./bs pi-herdr-subagents` to run just this step, then start Pi inside Herdr or run `/reload`.

If you installed the prototype with symlinks, move that directory outside Pi's `extensions` directory before running this target. Bootstrap leaves unrelated directories alone. Do not also install the repo with `pi install`, or Pi can load two copies of the extension. See the [extension README](https://github.com/murrayju/pi-herdr-subagents#readme) for usage.

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/murrayju/dotfiles/tarball/main | tar -xzv --strip-components 1 --exclude={README.md,macos.sh,LICENSE-MIT.txt} && ./bs
```

To update later on, just run that command again.

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/murrayju/dotfiles/blob/aff769fd75225d8f2e481185a71d5e05b76002dc/.aliases#L21-L26)) takes place.

Here’s an example `~/.path` file that adds `/usr/local/bin` to the `$PATH`:

```bash
export PATH="/usr/local/bin:$PATH"
```

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Justin Murray"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --file ~/.gitconfig.local user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="murrayju@addpcs.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --file ~/.gitconfig.local user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/murrayju/dotfiles/fork) instead, though.

### Machine-specific git settings

`~/.gitconfig` is a symlink into this repository, so `git config --global` changes the tracked file. Put machine-specific git settings (for example, a work email) in `~/.gitconfig.local` instead. `~/.gitconfig` includes it last, so its values override:

```bash
git config --file ~/.gitconfig.local user.email "me@work.example"
```

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
./macos.sh
```

### Packages: Homebrew, apt, and mise

The bootstrap uses three package managers:

- **Homebrew** (`Brewfile`): system tools, libraries, fonts, and apps. The file is a Ruby DSL with `if OS.mac?` / `if OS.linux?` blocks, so `brew bundle --file Brewfile` is valid on either platform. macOS gets the GNU userland and casks; Linux gets only what Homebrew is genuinely best at (fonts), because anything with system integration has to come from the distro.
- **apt** (`packages/apt.txt`, `./bs apt`): Debian/Ubuntu packages (gnupg, openssh-client, bash-completion, bubblewrap, …). Linux-only and opt-in, because it needs sudo.
- **mise** (`dotfiles/.config/mise/config.toml`): language runtimes and developer CLIs (Node, Go, Neovim, ripgrep, starship, and more). Projects can pin their own versions with a `mise.toml` or `.tool-versions` file.
- **pi** (`targets/pi.ts`, `./bs pi`): installed with <https://pi.dev/install.sh> when it is missing. Not a package manager, but it is the one tool that installs itself outside of them.
- **Concentrate CLI** (`targets/concentrate.ts`, `./bs concentrate`): installed with its [install script](https://github.com/concentrateai-hq/cli) when `cn` is missing. Like pi, it installs itself outside the package managers and only needs Node.js 22.13+ (from mise).
- **Concentrate API key** (`targets/concentrate-key.ts`, `./bs concentrate-key`): asks for the key with `cn key` when cn has none saved, so the secret stays in cn's own config directory. Skipped when a key is saved, when `CONCENTRATE_API_KEY` is set, or when stdin is not a terminal.
- **Pi catalog pruner** (`bin/pi-concentrate-prune`, `targets/concentrate-prune.ts`, `./bs concentrate-prune`): copied to `~/bin` on every bootstrap, then `cn refresh` runs and the pruner keeps the newest model of each chosen line.
- **pi preferences** (`pi/settings.json`, `targets/pi-settings.ts`, `./bs pi-settings`): merged into `~/.pi/agent/settings.json` on every bootstrap. Only the managed keys are written, so pi's changelog stamps and any setting changed inside pi stay as they are.
- **agent skills** (`targets/skills.ts`, `./bs skills`): clones <https://github.com/murrayju/skills> into `~/.agents/skills`, the directory pi discovers skills in, and fast-forwards it to latest `main` on every bootstrap. Updating is best-effort: an offline machine, local commits, a diverged history, or a branch other than `main` only warns, so the rest of the bootstrap still runs. Skills that other tools install in that directory are left alone, so a directory those tools create before the first bootstrap is not replaced; the step warns about it instead.

Separately from those, the bootstrap's own tooling (`build-strap`, `fs-extra`, `typescript`, `prettier`) is installed by **bun** into `node_modules` from `package.json` and `bun.lock`. Bun itself is not a prerequisite: `./bun` is a [bun-strap](https://github.com/murrayju/bun-strap) copy that downloads the pinned version into `download/bun/`. The shell config adds a `bun` function that prefers a project-local `./bun` and otherwise falls back to the globally installed one.

Path order matters. On macOS, Homebrew is prepended to `$PATH` so its modern GNU tools win. On Linux it is **appended**, because Homebrew's `bin` directory also contains duplicates of `gpg`, `ssh`, `python3`, `curl`, `sed`, `grep`, `dbus-*` and friends — and those must keep resolving to the distro's copies so they talk to the system's agents and services (most notably Ubuntu's systemd-managed `gpg-agent`, which breaks commit signing when a different `gpg` version talks to it). Tools you do want from Homebrew on Linux should be symlinked into `~/.local/bin`, which is ahead of everything. mise activates last, so mise tools beat both.

For the same reason, the bootstrap appends the Linux Homebrew prefixes to its own process `$PATH` before it runs the installer (`putLinuxBrewOnProcessPath` in `targets/bootstrap.ts`). The installer only prints its "`/home/linuxbrew/.linuxbrew/bin` is not in your PATH" warning — and points at the `Next steps` snippet — when the prefix is missing from `$PATH` at install time, and following that snippet on Linux is exactly what breaks the ordering above. Seeding it also means `build-strap` finds `brew` by itself afterwards instead of appending `eval "$(brew shellenv)"` to the (symlinked) `.zshrc`.

### Migrating an existing Linux install

Because the Linux branch of the `Brewfile` no longer installs anything that duplicates distro tools, previously installed formulae stay behind as dead weight (they no longer shadow anything, since Homebrew is appended to `$PATH`):

```bash
# Check for dependents first; only remove what nothing else needs.
brew uses --installed gnupg openssh screen php grep findutils coreutils gnu-sed
brew uninstall gnupg openssh screen php grep findutils coreutils gnu-sed

# Let the system gpg-agent take over again (note: /usr/bin/gpgconf).
/usr/bin/gpgconf --kill gpg-agent
/usr/bin/gpg --list-secret-keys   # then test a signed commit
```

Finally, make sure `brew shellenv` is **not** left in `~/.extra`, `~/.profile`, or `~/.bashrc`. On Linux that re-prepends Homebrew and undoes the ordering above — which is exactly what makes `gpg` and `ssh` talk to the wrong agents.

### Platform-specific shell configuration

Shell config is layered. Each shared file is followed by a per-OS companion that `$OSTYPE`-detects at source time:

| Shared | macOS | Linux |
| --- | --- | --- |
| `.exports` | `.exports_darwin` | `.exports_linux` |
| `.aliases` | `.aliases_darwin` | `.aliases_linux` |
| `.functions` | `.functions_darwin` | `.functions_linux` |

So an alias that only works on macOS (Finder, `defaults`, `pbcopy`, Spotlight) belongs in `.aliases_darwin`, and one that only works on Linux (bwrap, `ip`, `loginctl`) belongs in `.aliases_linux` / `.functions_linux`. `.extra` is sourced last and always wins. New OS-specific files are picked up automatically by the bootstrap symlinks; no bootstrap change is needed.

## Feedback

Suggestions/improvements
[welcome](https://github.com/murrayju/dotfiles/issues)!

## Original Author

| [![twitter/mathias](http://gravatar.com/avatar/24e08a9ea84deb17ae121074d0f17125?s=70)](http://twitter.com/mathias "Follow @mathias on Twitter") |
| ----------------------------------------------------------------------------------------------------------------------------------------------- |
| [Mathias Bynens](https://mathiasbynens.be/)                                                                                                     |

## Thanks to…

- @ptb and [his _macOS Setup_ repository](https://github.com/ptb/mac-setup)
- [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)
- [Cătălin Mariș](https://github.com/alrra) and his [dotfiles repository](https://github.com/alrra/dotfiles)
- [Gianni Chiappetta](https://butt.zone/) for sharing his [amazing collection of dotfiles](https://github.com/gf3/dotfiles)
- [Jan Moesen](http://jan.moesen.nu/) and his [ancient `.bash_profile`](https://gist.github.com/1156154) + [shiny _tilde_ repository](https://github.com/janmoesen/tilde)
- [Lauri ‘Lri’ Ranta](http://lri.me/) for sharing [loads of hidden preferences](http://osxnotes.net/defaults.html)
- [Matijs Brinkhuis](https://matijs.brinkhu.is/) and his [dotfiles repository](https://github.com/matijs/dotfiles)
- [Nicolas Gallagher](http://nicolasgallagher.com/) and his [dotfiles repository](https://github.com/necolas/dotfiles)
- [Sindre Sorhus](https://sindresorhus.com/)
- [Tom Ryder](https://sanctum.geek.nz/) and his [dotfiles repository](https://sanctum.geek.nz/cgit/dotfiles.git/about)
- [Kevin Suttle](http://kevinsuttle.com/) and his [dotfiles repository](https://github.com/kevinSuttle/dotfiles) and [macOS-Defaults project](https://github.com/kevinSuttle/macOS-Defaults), which aims to provide better documentation for [`~/.macos`](https://mths.be/macos)
- [Haralan Dobrev](https://hkdobrev.com/)
- Anyone who [contributed a patch](https://github.com/mathiasbynens/dotfiles/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)
