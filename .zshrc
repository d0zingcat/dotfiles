export GOPATH=$HOME/.go
export GOPROXY=https://goproxy.cn,direct

export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

export CARGO_PATH=$HOME/.cargo

export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
export PATH="$CARGO_PATH/bin:$GOPATH/bin:$PYENV_ROOT/shims:$PATH"
export PATH="$HOME/.local/bin:${HOME}/.krew/bin:$PATH"

source $HOME/.antigen/antigen.zsh

antigen use oh-my-zsh

antigen bundle git
antigen bundle pip
antigen bundle kubectl
antigen bundle pyenv
antigen bundle vi-mode
antigen bundle autojump
antigen bundle Aloxaf/fzf-tab
antigen bundle wbingli/zsh-wakatime

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions

#antigen theme spaceship-prompt/spaceship-prompt

antigen apply

eval "$(starship init zsh)"

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8
export MANPAGER="sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' \
    -c 'nnoremap i <nop>' \
    -c 'nnoremap <Space> <C-f>' \
    -c 'noremap q :quit<CR>' -\""
export KUBECONFIG=$(echo `ls ~/.kube/*config*` | sed 's/ /:/g')
export FZF_DEFAULT_OPTS="--height=50% --layout=reverse"

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


autoload -Uz compinit
compinit

source <(kubectl completion zsh)
source <(helm completion zsh)


alias ta='tmux a'
alias fixscreen='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist &&  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'
alias urldecode='python3 -c "import sys, urllib.parse as ul; \
    print(ul.unquote_plus(sys.argv[1]))"'
alias urlencode='python3 -c "import sys, urllib.parse as ul; \
    print (ul.quote_plus(sys.argv[1]))"'
alias zerotier_reload='sudo launchctl unload /Library/LaunchDaemons/com.zerotier.one.plist && sudo launchctl load /Library/LaunchDaemons/com.zerotier.one.plist'
alias git_branch="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
alias git_clean="git branch --merged | grep -v 'master' | grep -v 'main' | cat | xargs git branch -d"
#alias pyjson_decode='python3 -c "import sys, json; \
#print(json.dumps(eval(sys.argv[1])))"'
alias pyjson_decode_stdout='python3 -c "import sys, json, subprocess; \
    print(json.dumps(eval(subprocess.check_output( \
        \"pbpaste\", env={\"LANG\": \"en_US.UTF-8\"}).decode(\"utf-8\"))))"'
alias pyjson_decode='python3 -c "import json, subprocess; \
    output=json.dumps(eval(subprocess.check_output(\
        \"pbpaste\", env={\"LANG\": \"en_US.UTF-8\"}).decode(\"utf-8\"))).encode(\"utf-8\"); \
    process=subprocess.Popen(\"pbcopy\", env={\"LANG\": \"en_US.UTF-8\"}, stdin=subprocess.PIPE); \
    process.communicate(output)"'
alias ts_fmt='python3 -c "import datetime, subprocess; \
    print(\"UTC+800:\", datetime.datetime.fromtimestamp(int(subprocess.check_output(\"pbpaste\", env={\"LANG\": \"en_US.UTF-8\"}).decode(\"utf-8\")))); \
    print(\"UTC+000:\", datetime.datetime.fromtimestamp(int(subprocess.check_output(\"pbpaste\", env={\"LANG\": \"en_US.UTF-8\"}).decode(\"utf-8\"))-8*3600)); \
    "'
alias leetcode_today='curl -sL "https://leetcode-cn.com/graphql" -H "content-type: application/json" -d '\''{"operationName":"questionOfToday","variables":{},"query":"query questionOfToday {\n  todayRecord {\n    question {\n      questionFrontendId\n      questionTitleSlug\n      __typename\n    }\n    lastSubmission {\n      id\n      __typename\n    }\n    date\n    userStatus\n    __typename\n  }\n}\n"}'\'' | jq '\''.data.todayRecord[0].question'\'''
alias clean_tmux_session='ls ~/.tmux/resurrect/* -1dtr | head -n 100  | xargs rm  -v'
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
alias vim='nvim'
alias vi='nvim'
alias jumper='ssh tangli@10.1.4.14 -p 32200'
alias wol_xps8940="host root.pi.d0zingcat.xyz | cut -d ' ' -f 4 | cat | xargs -I {} wakeonlan -i {} -p 30009 'FC:44:82:13:BA:0F'"
alias nerdctl='lima nerdctl'
alias docker='lima docker'
alias batc='bat --paging=never'


function workup() {
    if [[ -n "$TMUX" ]]; then
        return 0
    fi
    tmux ls -F '#{session_name}' | fzf --bind=enter:replace-query+print-query |xargs echo | read session  && tmux attach -t ${session:-default} || tmux new -s ${session:-default}
}


# kill porcess according to keyword
function s_kill() {
         key=$1
         if [ -z "$key" ]; then
               echo "plz specify at least one keyword"
         fi
         ps -ef | grep $key | head -n 1 | awk '{print $2}' | xargs kill
}

macnst (){
    netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
}

# proxy by clashx
function clashproxy() {
    # shadowsocksx-r
    local proxy=http://127.0.0.1:7890
    export https_proxy=$proxy http_proxy=$proxy all_proxy=socks5://127.0.0.1:7891;
    echo "proxy all set!"
}

# unset proxy
function clashproxy_unset() {
    unset http_proxy
    unset https_proxy
    unset all_proxy
    echo "proxy all unset!"
}
function flush-input() {
    sudo killall -9 PAH_Extension TextInputMenuAgent TextInputSwitcher
}

function klogs() {
    keyword=$1
    k get pods --sort-by=.metadata.creationTimestamp | grep "$keyword" | head -n 1 | awk '{print $1}' | xargs kubectl logs -f
}



#export LESS_TERMCAP_so=$'\E[30;43m'

if [ $(uname -m) = 'arm64' ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#neofetch

#export LDFLAGS="-L/usr/local/opt/llvm/lib -L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib -L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
#export CPPFLAGS="-I/usr/local/opt/llvm/include -I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"
#export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
[ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ] &&  .  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

compdef __start_kubectl k

