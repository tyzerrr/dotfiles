# NOTE: This is the most important to use C-e in tmux env
bindkey -e

# alias
alias vi="nvim"
alias vim="nvim"
alias clip="pbcopy"
alias ls='lsd -F --hyperlink=auto'
alias lgit="lazygit"

# option
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt GLOBDOTS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt NO_FLOW_CONTROL
setopt NO_CLOBBER
setopt HIST_IGNORE_DUPS
setopt HIST_NO_STORE

# zsh theme(zenosh)
source /opt/homebrew/share/zsh/site-functions/async
prompt_precmd() {
  PROMPT=$(zenosh --instant)
  async_stop_worker prompt_async_worker
  async_start_worker prompt_async_worker -n
  async_register_callback prompt_async_worker prompt_async_callback
  async_job prompt_async_worker prompt_async_prompt
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_precmd

prompt_async_prompt() {
  zenosh
}
prompt_async_callback() {
  PROMPT="$3"
  zle reset-prompt
}

# If exit status is not 0, not added history
zshaddhistory() {
    local line="${1%%$'\n'}"
    [[ ! "$line" =~ "^(cd|jj?|lazygit|la|ll|ls|rm|rmdir)($| )" ]]
}

# NOTE: Git custom functions
git() {
    if ! command -v "git-$1" > /dev/null; then
        command git "${@:1}"
    else
        "git-$1" "${@:2}"
    fi
}

git-change() {
    command git checkout $(git branch --all | fzf)
}

# NOTE: Docker custom functions
docker() {
    if [ "$1" = "compose" ] || ! command -v "docker-$1" >/dev/null; then
        command docker "${@:1}" # 通常通りdockerコマンドを呼び出す
    else
        "docker-$1" "${@:2}" # docker-foo というコマンドが存在するときはそちらを起動する
    fi
}

# Exitedなプロセスを全て消去する
docker-clean() {
    command docker ps -aqf status=exited | xargs -r docker rm --
}

# Untaggedなイメージを全て削除する
docker-cleani() {
    command docker images -qf dangling=true | xargs -r docker rmi --
}

# 引数なしのdocker rmはfzfで起動する
docker-rm() {
    if [ "$#" -eq 0 ]; then
        command docker ps -a | fzf --exit-0 --multi --header-lines=1 | awk '{ print $1 }' | xargs -r docker rm --
    else
        command docker rm "$@"
    fi
}

# 引数なしのdocker rmiはfzfで起動する
docker-rmi() {
    if [ "$#" -eq 0 ]; then
        command docker images | fzf --exit-0 --multi --header-lines=1 | awk '{ print $3 }' | xargs -r docker rmi --
    else
        command docker rmi "$@"
    fi
}

# hooks
eval "$(direnv hook zsh)"
eval "$(sheldon source)"
