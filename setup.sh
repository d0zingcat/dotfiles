#!/usr/bin/env zsh
# Working environment: macOS/ArchLinux

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

CUSTOM_FILES=(
    "ssh/config .ssh/config"
    "git/config .gitconfig"
)

WORKING_DIR=$(pwd)
HOME_DIR="$HOME"

UNAME_LINUX="Linux"
UNAME_MACOS="Darwin"

RELEASE_ARCH="Arch Linux"
RELEASE_UBUNTU="Ubuntu"
RELEASE_DEBIAN="Debian"
RELEASE_MANJARO="Manjaro Linux"
RELEASE_MACOS="macOS"


release_name=$(cat /etc/*release| egrep '^NAME=' | sed -E 's/.*"(.*)"/\1/')
is_brew_installed="$+commands[brew]"
_uname=`uname`
is_linux=0
is_macos=0

if [ $_uname = $UNAME_LINUX ]
then
    is_linux=1
fi

if [ $_uname = $UNAME_MACOS ]
then
    is_macos=1
fi

function init() {
	sudo xcode-select --install
	sudo xcodebuild -license accept
k   git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
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
    mkdir $HOME/.ssh
    mkdir $HOME/.config/

	# dotfiles
    echo "Linking files..."
    for i in ${FILES[@]}; do
        ln -svfn $WORKING_DIR/$i $HOME_DIR/$i
    done

    echo "Linking config files..."
    for i in ${CONFIG_FILES[@]}; do
        ln -svfn $WORKING_DIR/$i $HOME_DIR/.config/$i
    done

    echo 'Linking customized files'
    for row in ${CUSTOM_FILES[@]}; do
        IFS=' ' read -r from to <<< "$row"
        ln -svfn $WORKING_DIR/$from $HOME_DIR/$to
    done

    # submodules
    echo 'Syncing Submodules...'
    git submodule init
    git submodule update --init --recursive
    git submodule foreach --recursive git fetch
    git submodule foreach git merge origin master

    # brew bundle
    if (( $is_brew_installed ))
    then
        echo "Installing by brew..."
        suffix="$OS."$(echo $(hostname) | cut -d '.' -f 1)
        mv .Brewfile.$suffix Brewfile
        brew bundle -v
        mv Brewfile .Brewfile.$suffix
    fi

    # if it is arch
    if [ $is_linux -eq 1 ] && [ $release_name = $RELEASE_ARCH ]
    then
        sudo pacman -S - < pkglist.txt
    fi

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
    if (( $is_brew_installed ))
    then
        # brew backup
        brew tap Homebrew/bundle
        brew bundle dump -f
        mv Brewfile .Brewfile."$(uname)."$(echo $(hostname) | cut -d '.' -f 1)
    fi
    if [ $is_linux -eq 1 ] && [ $release_name = $RELEASE_ARCH ]
    then
        pacman -Qqe > pkglist.txt
    fi
}

function purge() {
	uninstall_oh_my_zsh
	brew remove $(brew list --formula)
	for i in ${FILE_OR_DIRS[@]}; do
		rm -rf $WORKING_DIR/$i $HOME_DIR/$i
	done

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

option=$1
case $option in 
"")
    recover
    ;;
*)
    backup
    ;;
esac

exit 0
