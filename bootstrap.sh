#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function doIt() {
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "win/" \
		--exclude "*.bat" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
	curl -fsSL https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh | sh -s ~/.vim/
	vim -c "call dein#install()" +qall
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
