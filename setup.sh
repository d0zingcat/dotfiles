#!/usr/bin/env bash
# this is a script to setup dotfiles for myself.
set -x
FILES=(
	.gitignore

	.zshrc
	.zlogin

	.tmux.conf
	.ideavimrc

    .npmrc

)

CONFIG_FILES=(
	nvim
	git
	tmux
	raycast
	wezterm
	pycodestyle
	starship.toml
	stylua.toml
)

WORKING_DIR=$(pwd)
HOME_DIR="$HOME"

function init() {
	sudo xcode-select --install
	sudo xcodebuild -license accept
	if [[ $(command -v brew) = "" ]]; then
		echo "Installing brew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		eval "$(/opt/homebrew/bin/brew shellenv)"
		brew update
		brew install zsh
		chsh -s /bin/zsh
		ssh-keygen
		echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zshrc"
		source "$HOME/.zshrc"
	fi
}

function recover() {
	OS="$(uname)"

	# Homebrew
	if [ ! $(which brew) ]; then
		echo "Installing homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	if [ "$OS" = 'Darwin' ]; then
		export PATH=/usr/local/bin/:$PATH
	elif [ "$OS" = 'Linux' ]; then
		export PATH=/home/linuxbrew/.linuxbrew/bin/:$PATH
	fi

	# antigen
	if [ ! -f $HOME/.antigen/antigen.zsh ]; then
		mkdir -p $HOME/.antigen/
		curl -L git.io/antigen >$HOME/.antigen/antigen.zsh
	fi

	mkdir -p $HOME/.kube/

	# dotfiles
	echo "Linking files..."
	for i in ${FILES[@]}; do
		ln -svfn $WORKING_DIR/$i $HOME_DIR/$i
	done

	echo "Linking config files..."
	for i in ${CONFIG_FILES[@]}; do
		ln -svfn $WORKING_DIR/$i $HOME_DIR/.config/$i
	done

	# submodules
	echo 'Syncing Submodules...'
	git submodule init
	git submodule update --init --recursive
	git submodule foreach --recursive git fetch
	git submodule foreach git merge origin master

	# brew bundle
	echo "Installing by brew..."
	suffix="$OS."$(echo $(hostname) | cut -d '.' -f 1)
	mv .Brewfile.$suffix Brewfile
	brew bundle -v
	mv Brewfile .Brewfile.$suffix

	# others
	git config --global core.excludesfile ~/.config/git/.gitignore
	git config --global init.defaultBranch main
	$(brew --prefix)/opt/fzf/install
}

function manual_install() {
	wget -qO- http://stevenygard.com/download/class-dump-3.5.tar.gz | tar xvz - -C /usr/local/bin && chmod u+x /usr/local/bin/class-dump
	wget -O /usr/local/bin/class-dump https://github.com/AloneMonkey/MonkeyDev/raw/master/bin/class-dump && chmod u+x /usr/local/bin/class-dump
	pip install --user frida-tools
}

function backup() {
	# brew backup
	brew tap Homebrew/bundle
	brew bundle dump -f
	mv Brewfile .Brewfile."$(uname)."$(echo $(hostname) | cut -d '.' -f 1)
}

function purge() {
	uninstall_oh_my_zsh
	brew remove $(brew list --formula)
	for i in ${FILE_OR_DIRS[@]}; do
		rm -rf $WORKING_DIR/$i $HOME_DIR/$i
	done

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

function usage() {
	echo "Try to backup/recover my dotfiles"
	echo " "
	echo "options:"
	echo "-m             mode, accept recover/backup/purge"
}

while getopts ":m:" opt; do
	case ${opt} in
	m)
		echo $OPTARG
		if [ "$OPTARG"x == "recover"x ]; then
			recover
		elif [ "$OPTARG"x == "backup"x ]; then
			backup
		else
			echo "Invalid option: -$OPTARG" >&2
		fi
		exit 0
		;;
	\?)
		usage
		exit 0
		;;
	esac
done
