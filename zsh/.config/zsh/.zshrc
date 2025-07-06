# NOTE: This is the most important to use C-e in tmux env
bindkey -e
bindkey -s ^k "tmux-sessionizer\n"
bindkey -s ^r "tmux-sessionizer list\n"
bindkey -s ^g "tmux-sessionizer delete\n"
bindkey -s ^h "tmux-sessionizer create\n"

# alias
alias vi="nvim"
alias vim="nvim"
alias clip="pbcopy"
alias gls='lsd -F --hyperlink=auto'
alias lgit="lazygit"
alias bs="builtin source"
alias ls="lsd"

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

# source function with zcompile (precompile)
source() {
    local input="$1"
    local cache="$input.zwc"
    # もしCacheがないか、古いキャッシュなら再度コンパイル
    if [[ ! -f "$cache" || "$input" -nt "$cache" ]]; then
        zcompile "$input"
    fi
    \builtin source "$@"
}

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

sheldon::load() {
    local profile="$1"
    local plugins_file="$XDG_CONFIG_HOME/zsh/plugins.toml"
    local cache_file="$XDG_CACHE_HOME/sheldon/$profile.zsh"
    if [[ ! -f "$cache_file" || "$plugins_file" -nt "$cache_file" ]]; then
        mkdir -p "$XDG_CACHE_HOME/sheldon"
        sheldon --profile="$profile" source > "$cache_file"
        zcompile "$cache_file"
    fi
    \builtin source "$cache_file"
}

sheldon::load eager

# hooks
eval "$(direnv hook zsh)"
