# Justin’s dotfiles

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want (I like to keep it in `~/.dotfiles`). The bootstrapper script will pull in the latest version and copy the files to your home folder.

#### Mac/Linux

```bash
git clone https://github.com/murrayju/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && source bootstrap.sh
```

To update, just run the bootstrap script again

```bash
cd ~/.dotfiles
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

#### Windows

```bat
git clone https://github.com/murrayju/dotfiles.git .dotfiles
cd .dotfiles
bootstrap.bat
```

To update, just run the bootstrap script again

```bat
cd .dotfiles
bootstrap.bat
```

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/murrayju/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh}
```

To update later on, just run that command again.

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/murrayju/dotfiles/blob/aff769fd75225d8f2e481185a71d5e05b76002dc/.aliases#L21-26)) takes place.

Here’s an example `~/.path` file that adds `~/utils` to the `$PATH`:

```bash
export PATH="$HOME/utils:$PATH"
```

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# PATH additions
export PATH="~/bin:$PATH"

# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Justin Murray"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="murrayju@addpcs.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/murrayju/dotfiles/fork_select) instead, though.

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./.osx
```

### Install Homebrew formulae

When setting up a new Mac, you may want to install some common Homebrew formulae (after installing Homebrew, of course):

```bash
./.brew
```

### Install Chocolatey Apps

When setting up a new PC, you can automate the process of installing some common, useful apps using Chocolatey Nuget. This script will install/update Chocolatey, and then install/update a list of apps.

```bat
ChocolateyBootstrap.bat
```

## Included vim plugins

### EasyMotion
<https://github.com/Lokaltog/vim-easymotion>

	,,{motion}

### fugitive.vim
<https://github.com/tpope/vim-fugitive>

	:Gstatus
	:Gedit
	:Gcommit
	:Gmove
	:Gremove
	:Ggrep

### TComment
<https://github.com/tomtom/tcomment_vim>

	gc{motion}   :: Toggle comments (for small comments within one line 
					the &filetype_inline style will be used, if 
					defined)
	gc<Count>c{motion} :: Toggle comment text with count argument 
						  (see |tcomment#Comment()|)
	gcc          :: Toggle comment for the current line
	gC{motion}   :: Comment region
	gCc          :: Comment the current line

In visual mode:

	gc           :: Toggle comments
	gC           :: Comment selected text

### unimpaired.vim
<https://github.com/tpope/vim-unimpaired>

	[<Space>	:: newline before
	]<Space>	:: newline after
	[e			:: exchange with above
	]e			:: exchange with below
	[x			:: XML encode
	]x			:: XML decode
	[u			:: URL encode
	]u			:: URL decode
	[y			:: C string escape
	]y			:: C string un-escape

### surround.vim
<https://github.com/tpope/vim-surround>

	cs"'	:: Change surround from " to '
	cs'<q>	:: Change surround from ' to <q>
	cst"	:: Change surround from tag to "
	ds"		:: Delete the " surround
	ysiw]	:: Create new surround of [] around current word
	yss)	:: Create new surround of () around entire line

In visual mode:

	S<p class="important">	:: surround and indent the selected lines with the <p> tag

## AutoHotkey Scripts

The `bootstrap.bat` file will automatically launch `Main.ahk`, and configure it to start on boot.

### `F4` Edit in Vim

Highlight any file in explorer, or any text path in any application, and press `F4` to open the path for editing in Vim.

## Visual Studio Tweaks

### Edit current file in Vim
1.	Go to `Tools->External Tools...`
1.	`Add` a new entry:
	*	_Title:_ `&Vim`
	*	_Command:_ `C:\Program Files (x86)\vim\vim73\gvim.exe`
	*	_Arguments:_ `--servername VimStudio --remote-silent +"call cursor($(CurLine),$(CurCol))" "$(ItemFileName)$(ItemExt)"`
	*	_Initial directory:_ `$(ItemDir)`
1.	Move this entry to the top of the list, so that it is command number 1.
1.	Next, map this to a keyboard shortcut. Go to `Tools->Options...`, `Environment->Keyboard`.
1.	Locate the command `Tools.ExternalCommand1`
1.	Assign it to a shortcut key: _Global_ `F4`

## Feedback

Suggestions/improvements
[welcome](https://github.com/murrayju/dotfiles/issues)!
