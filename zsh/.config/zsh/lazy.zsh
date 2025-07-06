case "$OSTYPE" in
    darwin*)
        (( ${+commands[gdate]} )) && alias date='gdate'
        (( ${+commands[gls]} )) && alias ls='gls'
        (( ${+commands[gmkdir]} )) && alias mkdir='gmkdir'
        (( ${+commands[gcp]} )) && alias cp='gcp'
        (( ${+commands[gmv]} )) && alias mv='gmv'
        (( ${+commands[grm]} )) && alias rm='grm'
        (( ${+commands[gdu]} )) && alias du='gdu'
        (( ${+commands[ghead]} )) && alias head='ghead'
        (( ${+commands[gtail]} )) && alias tail='gtail'
        (( ${+commands[gsed]} )) && alias sed='gsed'
        (( ${+commands[ggrep]} )) && alias grep='ggrep'
        (( ${+commands[gfind]} )) && alias find='gfind'
        (( ${+commands[gdirname]} )) && alias dirname='gdirname'
        (( ${+commands[gxargs]} )) && alias xargs='gxargs'
    ;;
esac

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

sheldon::load lazy
