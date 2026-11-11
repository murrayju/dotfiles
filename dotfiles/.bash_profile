# Load Homebrew. Look in the default install paths for macOS and Linux.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [ -x "$brew_bin" ]; then
    brew_prefix="$(dirname "$(dirname "$brew_bin")")"
    case "$OSTYPE" in
      darwin*)
        # On macOS, Homebrew provides the modern GNU userland, so put it ahead
        # of the ancient tools that ship with the OS.
        eval "$("$brew_bin" shellenv bash)"
        ;;
      *)
        # On Linux, append instead of prepend. Homebrew's bin directory holds
        # duplicates of core system tools (gpg, ssh, python3, perl, curl,
        # openssl, sed, grep, dbus-*, gsettings, ...) and those must keep
        # resolving to the distro's copies so they talk to the system's agents
        # and services. Symlink the few tools you want from Homebrew into
        # ~/.local/bin, which is ahead of everything else.
        export HOMEBREW_PREFIX="$brew_prefix"
        export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
        export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
        case ":$PATH:" in
          *":$HOMEBREW_PREFIX/bin:"*) ;;
          *) PATH="$PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin" ;;
        esac
        export PATH
        ;;
    esac
    break
  fi
done
unset brew_bin brew_prefix

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Activate mise before the shell dotfiles, so that they can find mise tools.
# mise puts its tools before ~/.local/bin, so they come before the Homebrew tools.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# Load the shell dotfiles, and then some. Each shared file is followed by its
# per-OS companion (`.aliases_darwin` / `.aliases_linux`), so the OS layer can
# override the shared layer but never the other way around.
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
case "$OSTYPE" in
  darwin*) dotfiles_os=darwin ;;
  linux*) dotfiles_os=linux ;;
  *) dotfiles_os=other ;;
esac
export DOTFILES_OS="$dotfiles_os"

for file in ~/.path ~/.exports ~/".exports_$dotfiles_os" \
            ~/.aliases ~/".aliases_$dotfiles_os" \
            ~/.functions ~/".functions_$dotfiles_os" \
            ~/.extra ~/.bash_extra; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file dotfiles_os

# Load dircolors where available (GNU coreutils; on macOS this needs Homebrew
# coreutils in `$PATH`).
command -v dircolors >/dev/null 2>&1 && { eval "$(dircolors -b ~/.dir_colors)"; }

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# enable vi style command line editing
set -o vi

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2>/dev/null
done

# Add tab completion for many Bash commands. Source exactly one completion
# framework: Homebrew's on macOS, or the distro's bash-completion on Linux.
if command -v brew >/dev/null 2>&1 && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
  brew_prefix="$(brew --prefix)"
  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="${brew_prefix}/etc/bash_completion.d"
  source "${brew_prefix}/etc/profile.d/bash_completion.sh"
  unset brew_prefix
elif [ -r /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &>/dev/null; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

case "$OSTYPE" in
  darwin*)
    # Add tab completion for `defaults read|write NSGlobalDomain`
    # You could just use `-g` instead, but I like being explicit
    complete -W "NSGlobalDomain" defaults

    # Add `killall` tab completion for common apps
    complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
    ;;
esac
