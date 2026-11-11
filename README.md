# Justin’s dotfiles

![Screenshot of my shell prompt](https://i.imgur.com/EkEtphC.png)

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

### Using Git and the modern bootstrap system

You can clone the repository wherever you want (I like to keep it in `~/.dotfiles`). The modern bootstrapper uses JavaScript and will automatically handle Node.js installation, symlink creation, and backup of existing files.

#### macOS/Linux

```bash
git clone https://github.com/murrayju/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./bs
```

To update, just run the bootstrap script again

```bash
cd ~/.dotfiles && ./bs
```

The new bootstrap system will:

- Automatically install Node.js if needed using build-strap-cli
- Create symlinks from the repository to your home directory
- Back up any existing files that differ from the repository versions
- Install Oh My Zsh, Powerlevel10k theme, and Tmux Plugin Manager
- Install [Homebrew](https://brew.sh/) and the formulae in `Brewfile` (macOS and Linux)
- Install [mise](https://mise.jdx.dev/) and the tools in `dotfiles/.config/mise/config.toml`
- Set up the modern Neovim configuration

On Linux the bootstrap does **not** install distro packages. Do that once, separately (it needs sudo):

```bash
cd ~/.dotfiles && ./bs apt
```

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/murrayju/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,macos.sh,LICENSE-MIT.txt} && ./bs
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

Path order matters. On macOS, Homebrew is prepended to `$PATH` so its modern GNU tools win. On Linux it is **appended**, because Homebrew's `bin` directory also contains duplicates of `gpg`, `ssh`, `python3`, `curl`, `sed`, `grep`, `dbus-*` and friends — and those must keep resolving to the distro's copies so they talk to the system's agents and services (most notably Ubuntu's systemd-managed `gpg-agent`, which breaks commit signing when a different `gpg` version talks to it). Tools you do want from Homebrew on Linux should be symlinked into `~/.local/bin`, which is ahead of everything. mise activates last, so mise tools beat both.

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
