#!/usr/bin/env zsh

set -e

FILES=(
	.zshrc
	.tmux.conf
	.ideavimrc
)

CONFIG_FILES=(
	git
	nvim
	tmux
	pycodestyle
  wezterm
	starship.toml
	stylua.toml
	direnv
)

CUSTOM_FILES=(
    #"ssh/config .ssh/config"
    "git/config .gitconfig"
    #"logseq .logseq"
)

RUSTUP_COMPONENTS=(
  clippy
)

KUBECTl_COMPONENTS=(
    # ctx
    # ns
    # tail
    # tree
    # view-secret
    # who-can
    # cost
    # neat
    # sniff
    # access-matrix
    # pod-dive
    # pod-chaos
    # pod-lease
    # pod-shell
    # pod-logs
    # pod-attach
    # pod-exec
    # pod-port-forward
)

WORKING_DIR=$(pwd)
HOME_DIR="$HOME"
is_brew_installed="$+commands[brew]"


function command_exists() {
    # Check if a command exists
    # Usage: command_exists <command_name>
    local cmd="$1"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0  # Command exists
    else
        return 1  # Command does not exist
    fi
}

function init() {
	sudo xcode-select --install
	sudo xcodebuild -license accept
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
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

function purge() {
	uninstall_oh_my_zsh
	brew remove $(brew list --formula)
	for i in ${FILE_OR_DIRS[@]}; do
		rm -rf $WORKING_DIR/$i $HOME_DIR/$i
	done

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

function manual_install() {
	wget -qO- http://stevenygard.com/download/class-dump-3.5.tar.gz | tar xvz - -C /usr/local/bin && chmod u+x /usr/local/bin/class-dump
	wget -O /usr/local/bin/class-dump https://github.com/AloneMonkey/MonkeyDev/raw/master/bin/class-dump && chmod u+x /usr/local/bin/class-dump
	pip install --user frida-tools
    # mkdir -p $ZSH/custom/plugins/poetry
    # poetry completions zsh > $ZSH/custom/plugins/poetry/_poetry
}

function backup() {
    brew bundle dump -f
}

function softLink() {
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
}

function recover() {
    #softwareupdate --install-rosetta
    OS="$(uname)"

    # Homebrew
    if [ ! $(which brew) ]; then
        echo "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    export PATH=/usr/local/bin/:$PATH
    xcode-select --install
    defaults write -g ApplePressAndHoldEnabled -bool false

    # antigen
    if [ ! -f $HOME/.antigen/antigen.zsh ]; then
        mkdir -p $HOME/.antigen/
        curl -L git.io/antigen >$HOME/.antigen/antigen.zsh
    fi

    mkdir -p $HOME/.kube/
    mkdir $HOME/.ssh
    mkdir $HOME/.config/

    # dotfiles
    cp ssh/example $HOME/.ssh/config

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

    mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock

    # others
    git config --global core.excludesfile ~/.config/git/.gitignore
    git config --global init.defaultBranch main
    $(brew --prefix)/opt/fzf/install
}

function recover_rust() {
  # install rustup
  if ! command_exists rustup; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
  # cargo commands installation
  for command in ${RUSTUP_COMPONENTS[@]}; do
    if ! command_exists $command; then
      rustup component add $command
    fi
  done
}

function recover_kubectl() {
    # krew installation
    if ! command_exists kubectl-krew; then
        (
        set -x; cd "$(mktemp -d)" &&
        OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        KREW="krew-${OS}_${ARCH}" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
        tar zxvf "${KREW}.tar.gz" &&
        ./"${KREW}" install krew
        )
    fi
    # kubectl plugins installation
    for plugin in ${KUBECTl_COMPONENTS[@]}; do
        if ! command_exists $plugin; then
        kubectl krew install $plugin
        fi
    done
}

function new_recover() {
    # recover_rust
    recover_kubectl
}

function post_recover() {
    mkdir -p ~/.1password && ln -s "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
}

option=$1
case $option in 
  recover)
    new_recover
    ;;
  uninstall)
    uninstall
    ;;
  backup)
    backup
    ;;
esac

exit 0
