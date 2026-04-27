
# Kiro CLI pre block. Keep at the top of this file.
# [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

###############################################################################
# My Dotfiles - Zsh Configuration
###############################################################################
# This configuration includes both personal and work-related functions.
# Work-related functions are marked with "# ==== WORK: xxx" comments.
###############################################################################

# -- Environment Variables --
export BREW_HOME="/opt/homebrew/"
export GOPATH="$HOME/.go"
export PNPM_HOME="$HOME/.pnpm"
export BUN_HOME="$HOME/.bun"
export CARGO_HOME="$HOME/.cargo"
export JAVA_HOME="$BREW_HOME/opt/openjdk@21"

export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin"
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
export PATH="$CARGO_HOME/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.local/bin:${HOME}/.krew/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export PATH="$BUN_HOME/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"
# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/d0zingcat/.lmstudio/bin"
# End of LM Studio CLI section
export PATH="$PATH:$JAVA_HOME/bin"

export LC_ALL=en_US.UTF-8
export EDITOR=vim
export LANG=en_US.UTF-8
export MANPAGER="sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu' \
    -c 'nnoremap i <nop>' \
    -c 'nnoremap <Space> <C-f>' \
    -c 'noremap q :quit<CR>' -\""
typeset -a kubeconfigs
kubeconfigs=("$HOME"/.kube/*config*(N))
if (( ${#kubeconfigs[@]} )); then
    export KUBECONFIG="${(j/:/)kubeconfigs}"
fi
export HELM_CACHE_HOME=$HOME/.cache/helm
export FZF_DEFAULT_OPTS="--height=50% --layout=reverse"
export GPG_TTY=$(tty)

arch=$(uname -m)
if [[ $arch == "x86_64" ]]; then
    brew_opt="/usr/local/opt"
elif [[ $arch == "arm64" ]]; then
    brew_opt="/opt/homebrew/opt"
fi
LDFLAGS="-L$brew_opt/zlib/lib -L$brew_opt/openssl@3/lib"
CPPFLAGS="-I$brew_opt/zlib/include -I$brew_opt/openssl@3/include"
export LDFLAGS=$LDFLAGS
export CPPFLAGS=$CPPFLAGS
export ZSH_HIGHLIGHT_MAXLENGTH=60
export GIT_EXTERNAL_DIFF=difft

FPATH="$brew_opt/share/zsh/site-functions:${FPATH}"
DISABLE_MAGIC_FUNCTIONS=true

HISTSIZE=10000         # Number of commands to remember in memory (in-session)
SAVEHIST=50000         # Number of commands to save to the history file
HISTFILE=~/.zsh_history  # File where history is stored

# -- Antigen for plugin management --
if [ -f "$HOME/.antigen/antigen.zsh" ]; then
    source "$HOME/.antigen/antigen.zsh"
    antigen use oh-my-zsh
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-completions
    antigen bundle git
    antigen bundle kubectl
    antigen bundle autojump
    antigen bundle pip
    antigen bundle nvim
    antigen bundle darvid/zsh-poetry
    antigen bundle Aloxaf/fzf-tab
    antigen bundle vi-mode
    antigen apply
else
    mkdir $HOME/.antigen
    curl -L git.io/antigen > $HOME/.antigen/antigen.zsh
fi

# -- Aliases --
alias ta='tmux a'
alias tl='tmux ls && read session && tmux attach -t ${session:-default} || tmux new -s ${session:-default}'
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
alias python='python3'
alias pip='pip3'
alias sed='gsed'
alias grep='ggrep'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias ghostty='/Applications/Ghostty.app/Contents/MacOS/ghostty'
alias cc='claude'
alias oc='opencode'

# -- Functions --
# menu
function m() {
    if [[ -n "$TMUX" ]]; then
        exit 0
    fi
    tmux ls -F '#{session_name}' | fzf --bind=enter:replace-query+print-query | xargs echo | read session  && tmux attach -t ${session:-default} || tmux new -s ${session:-default}
}

# find network ports
function macnst (){
    netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
}

# ==== WORK: Kubernetes logs viewer
function klogs() {
    keyword=$1
    k get pods --sort-by=.metadata.creationTimestamp | grep "$keyword" | head -n 1 | awk '{print $1}' | xargs kubectl logs -f
}

# ==== WORK: Git remote URL switcher
function replace_remote() {
    if (( $# != 1 ));
    then
        echo 'Invalid parameter!'
    else
        url=$(git remote -v | head -n 1  | cut -d $'\t' -f 2 | cut -d ' ' -f 1)
        suffix=$(echo $url | cut -d ':' -f 2)
        case $1 in
            ops)
                new_url=opsgit:$suffix
                git remote set-url origin $new_url
                ;;
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

# ==== WORK: Remote sync to work servers
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
            exit 1
        fi
    else
        echo "invalid argument!"
        exit 1
    fi
    rsync_exclude="$local_work/rsync_exclude.txt"
    if [ -f $rsync_exclude ]; then
        rsync -avhti --exclude-from=$rsync_exclude --exclude=/venv --exclude=/.vscode --exclude=/.git $local_work/ $remote_work
    else
        rsync -avhti --exclude=/venv --exclude=/.vscode --exclude=/.git $local_work/ $remote_work
    fi
}

function claude_with() {
  local name="$1"

  if [ -z "$name" ]; then
    echo "usage: claude_with <provider-name>"
    return 1
  fi

  # 根据 name 找 id
  local id
  id=$(cc-switch provider list | awk -F'┆' -v n="$name" '$3 ~ n {gsub(/ /,"",$2); print $2}')

  if [ -z "$id" ]; then
    echo "provider not found: $name"
    return 1
  fi

  # 当前 provider
  local old
  old=$(cc-switch provider list | awk -F'┆' '/✓/ {gsub(/ /,"",$2); print $2}')

  cc-switch provider switch "$id" || return 1

  claude
  local exit_code=$?

  # 恢复
  if [ "$old" != "$id" ]; then
    cc-switch provider switch "$old" >/dev/null
  fi

  return $exit_code
}


function git_clean() {
    git fetch --all --prune

    base_branch="$1"
    if [[ -z "$base_branch" ]]; then
        base_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
    fi

    if [[ -z "$base_branch" ]]; then
        for branch in main master develop; do
            if git show-ref --verify --quiet "refs/heads/$branch" || git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
                base_branch="$branch"
                break
            fi
        done
    fi

    if [[ -z "$base_branch" ]]; then
        echo 'Could not detect base branch. Pass it explicitly, e.g. git_clean main'
        return 1
    fi

    git checkout "$base_branch" && \
        git config pull.rebase false && \
        git pull && \
        git branch --merged | grep -v " $base_branch$" | xargs git branch -d 2>/dev/null; \
        git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D 2>/dev/null; \
        git worktree prune --verbose
}

function git_config() {
  git config user.name $1
  git config user.email $2
  git config gpg.format ssh
  git config user.signingkey "$3"
}

# ==== WORK: Multi-environment Git config (work)
function git_config_work() {
  if [ ! $# -eq 2 ]; then
    echo 'should be like git_config_work {name} {email}'
  fi
  git_config $1 $2 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF23DQtdH5PODF9fYUHr49I1J3lfKLAPk4LG54MVUTcg'
}

# ==== WORK: Multi-environment Git config (play)
function git_config_play() {
  if [ ! $# -eq 1 ]; then
    echo 'should be like git_config_play {email}'
  fi
  git_config d0zingcat $1 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaVruhhL4O9BiAncnW1wH3jc7/hsqsXLknA8Xtnjjee'
}

# ==== WORK: Kubernetes secret sealer
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

# Create dev workspace in tmux
# Usage: dev [-g] [session-name]
#   default: Claude Code | Yazi (top-right) + shell (bottom-right)
#   -g/--git: 2x2 layout adding lazygit (bottom-left)
function dev() {
    local session=""
    local layout="simple"
    local tool="cc"

    for arg in "$@"; do
        case "$arg" in
            -g|--git) layout="full" ;;
            oc|--oc) tool="oc" ;;
            cc|--cc) tool="cc" ;;
            codex|--codex) tool="codex" ;;
            copilot|--copilot) tool="copilot" ;;
            *) session="$arg" ;;
        esac
    done

    session="${session:-$(basename $(pwd))}"
    # Sanitize: tmux treats '.' and ':' as special in target strings
    session="${session//[.:]/_}"
    local cwd="$(pwd)"

    if tmux has-session -t "$session" 2>/dev/null; then
        if [[ -n "$TMUX" ]]; then
            tmux switch-client -t "$session"
        else
            tmux attach-session -t "$session"
        fi
        return
    fi

    # Create session; first pane = left (Claude Code)
    tmux new-session -d -s "$session" -c "$cwd"
    local left
    left=$(tmux display-message -p -t "${session}:1.1" "#{pane_id}")

    if [[ "$layout" == "full" ]]; then
        # 2x2: Claude Code | Yazi / shell | lazygit
        local tr
        tr=$(tmux split-window -t "$left" -h -c "$cwd" -P -F "#{pane_id}")
        local br
        br=$(tmux split-window -t "$tr"   -v -c "$cwd" -P -F "#{pane_id}")
        local bl
        bl=$(tmux split-window -t "$left" -v -c "$cwd" -P -F "#{pane_id}")

        # Only enable passthrough for yazi pane (image display); keep it off elsewhere
        # to prevent Ghostty DA/XTVERSION responses leaking into other panes' stdin.
        # tmux set-option -p -t "$tr" allow-passthrough on
        tmux send-keys -t "$left" "$tool"     Enter
        tmux send-keys -t "$tr"   "yazi"     Enter
        tmux send-keys -t "$br"   "lazygit"  Enter
    else
        # simple: Claude Code (left) | Yazi (top-right) + shell (bottom-right)
        local tr
        tr=$(tmux split-window -t "$left" -h -c "$cwd" -P -F "#{pane_id}")
        local br
        br=$(tmux split-window -t "$tr"   -v -c "$cwd" -P -F "#{pane_id}")

        # tmux set-option -p -t "$tr" allow-passthrough on
        tmux send-keys -t "$left" "$tool"    Enter
        tmux send-keys -t "$tr"   "yazi"  Enter
    fi

    tmux select-pane -t "$left"

    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    fi
}

# Create a throwaway scratch workspace in a temp dir
# Usage: scratch [-g] [--git] [oc|cc|codex|copilot]
#   Creates /tmp/scratch-<ts>, calls dev() for a throwaway workspace
#   --git: initialize a git repo in the temp dir (off by default)
#   The temp dir is cleaned up when the tmux session is destroyed
function scratch() {
    local extra_args=()
    local init_git=false

    for arg in "$@"; do
        case "$arg" in
            --git) init_git=true ;;
            *) extra_args+=("$arg") ;;
        esac
    done

    local ts=$(date +%Y%m%d-%H%M%S)
    local dir="/tmp/scratch-${ts}"
    mkdir -p "$dir"

    if $init_git; then
        git -C "$dir" init -q
        git -C "$dir" commit --allow-empty -m "scratch init" -q
    fi

    pushd "$dir" > /dev/null

    local session="scratch_${ts}"
    dev "${extra_args[@]}" "$session"

    popd > /dev/null

    # Auto-cleanup: wait for the session to die, then remove the dir
    (
        while tmux has-session -t "$session" 2>/dev/null; do
            sleep 5
        done
        rm -rf "$dir"
    ) &>/dev/null &
    disown
}

# -- MISC Configuration --
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v lsd >/dev/null 2>&1 && alias ls='lsd'

export ZSH_COMPLETION_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_COMPLETION_CACHE"

if [[ $commands[kubectl] ]]; then
    if [[ ! -s "$ZSH_COMPLETION_CACHE/_kubectl" ]]; then
        command kubectl completion zsh >| "$ZSH_COMPLETION_CACHE/_kubectl" 2>/dev/null
    fi
    if [[ -s "$ZSH_COMPLETION_CACHE/_kubectl" ]]; then
        source "$ZSH_COMPLETION_CACHE/_kubectl"
        compdef __start_kubectl k
    fi
fi

if [[ $commands[helm] ]]; then
    if [[ ! -s "$ZSH_COMPLETION_CACHE/_helm" ]]; then
        command helm completion zsh >| "$ZSH_COMPLETION_CACHE/_helm" 2>/dev/null
    fi
    if [[ -s "$ZSH_COMPLETION_CACHE/_helm" ]]; then
        source "$ZSH_COMPLETION_CACHE/_helm"
    fi
fi
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
[ -f /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc ] &&  .  /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

if command -v fzf >/dev/null 2>&1; then
    if [[ ! -s "$ZSH_COMPLETION_CACHE/fzf.zsh" ]]; then
        command fzf --zsh >| "$ZSH_COMPLETION_CACHE/fzf.zsh" 2>/dev/null
    fi
    if [[ -s "$ZSH_COMPLETION_CACHE/fzf.zsh" ]]; then
        source "$ZSH_COMPLETION_CACHE/fzf.zsh"
    fi
fi

bindkey -M viins '^b' vi-backward-char
bindkey -M viins '^f' vi-forward-char
bindkey -M viins '^d' vi-delete-char
[ -f ~/.env ] && source ~/.env

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'


# Kiro CLI post block. Keep at the bottom of this file.
# [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

