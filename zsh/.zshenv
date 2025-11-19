### XDG ###
# References: https://wiki.archlinux.jp/index.php/XDG_Base_Directory
# XDG_CONFIG_HOME: User個別の設定が書き込まれる
# XDG_DATA_HOME: User個別のデータファイルが書き込まれる
# XDG_STATE_HOME: User個別の受胎ファイルが書き込まれる
# XDG_CACHE_HOME: User個別の重要でないデータが書き込まれる
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR=nvim
export SAVEHIST=100000
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
# export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export TERM="tmux-256color"
export HISTFILE="$XDG_STATE_HOME/zsh_history"
export GPG_TTY=$(tty)
### locale ###
# NOTE: エラーメッセージやツールの表示を英語にし、エンコードをUTF-8に固定する""
export LANG="en_US.UTF-8"

## /etc/zshrc, /etc/zshenvを読まない
# NOTE: Systemの設定は読まない
unsetopt GLOBAL_RCS

## zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

### Go ###
export GOPATH="$XDG_DATA_HOME/go"

### Deno ###
export DENO_INSTALL="$XDG_DATA_HOME/deno"
export DENO_INSTALL_ROOT="$DENO_INSTALL"

### sheldon ###
export SHELDON_CONFIG_DIR="$ZDOTDIR"
