# Load Homebrew. Look in the default install paths for macOS and Linux.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  if [ -x "$brew_bin" ]; then
    eval "$("$brew_bin" shellenv bash)"
    break
  fi
done
unset brew_bin

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Activate mise before the shell dotfiles, so that they can find mise tools.
# mise puts its tools before ~/.local/bin, so they come before the Homebrew tools.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt_airline,exports,aliases,functions,extra,bash_extra}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Load dircolors
command -v dircolors >/dev/null 2>&1 && { eval "$(dircolors ~/.dir_colors)"; }

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

brew_prefix="$(brew --prefix 2>/dev/null)"
# Add tab completion for many Bash commands
if which brew &>/dev/null && [ -r "${brew_prefix}/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="${brew_prefix}/etc/bash_completion.d"
  source "${brew_prefix}/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &>/dev/null; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# If possible, add tab completion for many more commands
[ -f /etc/bash_completion ] && source /etc/bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

