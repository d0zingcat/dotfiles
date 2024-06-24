export GOPATH=$HOME/.go
# export GOPROXY=https://goproxy.cn,direct
# export PYENV_ROOT="$HOME/.pyenv"
export PNPM_HOME="$HOME/.pnpm"
export CARGO_PATH=$HOME/.cargo

export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
export PATH="/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.linuxbrew/bin:$PATH"
# $PYENV_ROOT/shims
export PATH="$CARGO_PATH/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.local/bin:${HOME}/.krew/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export PATH="$HOME/.docker/bin:$PATH"

export LC_ALL=en_US.UTF-8  
export EDITOR=vim
export LANG=en_US.UTF-8
export MANPAGER="sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' \
    -c 'nnoremap i <nop>' \
    -c 'nnoremap <Space> <C-f>' \
    -c 'noremap q :quit<CR>' -\""
export KUBECONFIG=$(echo `ls ~/.kube/*config*` | sed 's/ /:/g')
export HELM_CACHE_HOME=$HOME/.cache/helm
export FZF_DEFAULT_OPTS="--height=50% --layout=reverse"
export GPG_TTY=$(tty)

arch=$(uname -m)
if [ $arch = "x86_64" ]; then
    brew_opt="/usr/local/opt"
elif [ $arch = "arm64" ]; then
    brew_opt="/opt/homebrew/opt"
fi
LDFLAGS="-L$brew_opt/zlib/lib -L$brew_opt/openssl@3/lib"
CPPFLAGS="-I$brew_opt/zlib/include -I$brew_opt/openssl@3/include"
export LDFLAGS=$LDFLAGS
export CPPFLAGS=$CPPFLAGS
export ZSH_HIGHLIGHT_MAXLENGTH=60
export GIT_EXTERNAL_DIFF=difft
export LIMA_INSTANCE=archlinux


FPATH="$brew_opt/share/zsh/site-functions:${ASDF_DIR}/completions:${FPATH}"
DISABLE_MAGIC_FUNCTIONS=true

alias python=python3

source $HOME/.antigen/antigen.zsh
antigen use oh-my-zsh
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle git
antigen bundle kubectl
antigen bundle autojump
antigen bundle pip
antigen bundle asdf
antigen bundle nvim
antigen bundle fzf
antigen bundle darvid/zsh-poetry
antigen bundle Aloxaf/fzf-tab
antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
antigen bundle jeffreytse/zsh-vi-mode
antigen apply


# menu
function m() {
    if [[ -n "$TMUX" ]]; then
        exit 0
    fi
    tmux ls -F '#{session_name}' | fzf --bind=enter:replace-query+print-query |xargs echo | read session  && tmux attach -t ${session:-default} || tmux new -s ${session:-default}
}

# find network ports
function macnst (){
    netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
}

# As clash for windows provides TUN mode/ClashX provides enhance mode, there's no necessity to set proxy munally(which proxy all traffix transparently)
# proxy by clashx function clashproxy() {
#    local proxy=http://127.0.0.1:7890
#    export https_proxy=$proxy http_proxy=$proxy all_proxy=socks5://127.0.0.1:7891;
#    echo "proxy all set!"
#}
#
## unset proxy
#function clashproxy_unset() {
#    unset http_proxy
#    unset https_proxy
#    unset all_proxy
#    echo "proxy all unset!"
#}

function flush-input() {
    sudo killall -9 PAH_Extension TextInputMenuAgent TextInputSwitcher
}

function klogs() {
    keyword=$1
    k get pods --sort-by=.metadata.creationTimestamp | grep "$keyword" | head -n 1 | awk '{print $1}' | xargs kubectl logs -f
}

function replace_remote() {
    if (( $# != 1 ));
    then
        echo 'Invalid parameter!'
    else
        url=$(git remote -v | head -n 1  | cut -d $'\t' -f 2 | cut -d ' ' -f 1)
        suffix=$(echo $url | cut -d ':' -f 2)
        case $1 in 
            work)
                new_url=workgit:$suffix
                git remote set-url origin $new_url
                ;;
            play)
                new_url=personalgit:$suffix
                git remote set-url origin $new_url
                ;;
            *)
                echo 'Invalid parameter'
                ;;
        esac
    fi
}

function rsync_work() {
    remote_dir="/root"
    local_work=`pwd`
    local_dir=${PWD##*/}
    local_dir=${local_dir:-/}
    if [ $# -eq 0 ]; then 
        remote_work="devops-cloud-1:$remote_dir/$local_dir"
    elif [ $# -eq 1 ]; then
        remote_work="devops-cloud-$1:$remote_dir/$local_dir"
    elif [ $# -eq 2 ]; then
        remote_work="devops-cloud-$1:$remote_dir/$local_dir"
        if [ "$2" = "back" ]; then
            # swap local and remote
            t=$local_work 
            local_work=$remote_work
            remote_work=$t
        else
            echo "Invalid argument! should be 'back'"
            exit(1)
        fi
    else
        echo "invalid argument!"
        exit(1)
    fi
    rsync_exclude="$local_work/rsync_exclude.txt"
    if [ -f $rsync_exclude ]; then
        rsync -avhti --exclude-from=$rsync_exclude --exclude=/venv --exclude=/.vscode --exclude=/.git $local_work/ $remote_work
    else
        rsync -avhti --exclude=/venv --exclude=/.vscode --exclude=/.git $local_work/ $remote_work
    fi
}

function git_clean() {
    if [[ $# != 1 || ! $1 =~ 'main|master|develop' ]]
    then 
        echo 'Invalid parameter, should based on develop/main/master' 
    else
        git fetch --all --prune
        git checkout $1 && \
            git config pull.rebase false && \
            git pull && \
            git branch --merged | grep -v $1 | cat | xargs git branch -d
    fi
}

function bitnami_seal() {
    if [[ $# != 2 ]]
    then 
        echo 'Invalid parameter, should be like bitnami_seal <namespace> <filename>'
    else
        if [[ ! -f $2 ]]
        then
            echo "The file does not exist"
            exit 1
        fi
        if [[ $2 != *".raw.yaml" ]]; then
            echo "The variable does not have the .raw.yaml extension"
            exit 1
        fi
        # parse *.raw.yaml to *.yaml
        newname=${2//.raw/} 
        kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets -oyaml -n $1 -f $2 > $newname
    fi
}

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

alias ta='tmux a'
alias tl='tmux ls && read session && tmux attach -t ${session:-default} || tmux new -s ${session:-default}'
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias kns='kubens'
alias kctx='kubectx'
alias kd='kubectl debug'
alias kk='kubectl krew'
alias kzeus='kubectl --context zeus '
alias khybrid='kubectl --context hybrid'
alias kget='kubectl get'
alias kdesc='kubectl describe'
alias klog='kubectl logs'
alias kapply='kubectl apply'
alias gce='gh copilot explain'
alias gcs='gh copilot suggest'
alias vi='nvim'
#alias wol_xps8940="host home.d0zingcat.xyz | cut -d ' ' -f 4 | cat | xargs -I {} wakeonlan -i {} -p 200 'FC:44:82:13:BA:0F'"
alias batc='bat --paging=never'
alias batcp='bat --plain --paging=never'
alias fixscreen='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist &&  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'
# do not use -r as it skips the non-regular files
alias tf_push='rsync -avhti . devops-cloud-1:~/meex-deploy/ --exclude=.terraform/ --exclude=.terraform.lock.hcl --exclude=terraform.tfstate'
alias tf_push_state='rsync -avhti . devops-cloud-1:~/meex-deploy/ --exclude=.terraform/ --exclude=.terraform.lock.hcl'
alias tf_pull_state='rsync -avhti devops-cloud-1:~/meex-deploy/terraform/terraform.tfstate terraform/.'
alias git_branch="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
alias clean_tmux_session='ls ~/.tmux/resurrect/* -1dtr | head -n 100  | xargs rm  -v'
alias pn='pnpm'

[[ $commands[kubectl] ]] && source <(kubectl completion zsh) && compdef __start_kubectl k
[[ $commands[helm] ]] && source <(helm completion zsh)
# [[ $commands[gh] ]] && source <(gh completion -s zsh)

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
[ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ] &&  .  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh 
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#export LESS_TERMCAP_so=$'\E[30;43m'

#export LDFLAGS="-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
#export CPPFLAGS="-I/usr/local/opt/llvm/include -I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
#export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

#eval "$(op completion zsh)"; compdef _op op
#export PYENV_VIRTUALENV_DISABLE_PROMPT=1
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/d0zingcat/.pyenv/versions/miniforge3-22.11.1-4/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/d0zingcat/.pyenv/versions/miniforge3-22.11.1-4/etc/profile.d/conda.sh" ]; then
#         . "/Users/d0zingcat/.pyenv/versions/miniforge3-22.11.1-4/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/d0zingcat/.pyenv/versions/miniforge3-22.11.1-4/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

