{
  config,
  lib,
  pkgs,
  ...
}:
let
  fzf-git = pkgs.fetchFromGitHub {
    owner = "junegunn";
    repo = "fzf-git.sh";
    rev = "0f0488331a060cf45aaecb6705a2cf394fb20293";
    hash = "sha256-fV4RtYL+ksbl5SMVZMoRyo6YUWP/KFvFPgfIbecIOO4=";
  };

  fdHidden = "fd --hidden --strip-cwd-prefix --exclude .git";
  dirPreview = "eza --tree --color=always {} | head -200";
  fileOrDirPreview = "if [ -d {} ]; then ${dirPreview}; else bat -n --color=always --line-range :500 {}; fi";
in
{
  imports = [ ./oh-my-posh.nix ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    # tmux 内で C-e を使うため emacs keymap を明示する
    defaultKeymap = "emacs";

    history = {
      path = "${config.xdg.stateHome}/zsh_history";
      # oh-my-zsh が HISTSIZE を 50000 に引き上げていた値を引き継ぐ
      size = 50000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      saveNoDups = true;
      share = true;
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      extraConfig = ''
        zstyle ':omz:update' mode disabled
      '';
    };

    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      clip = "pbcopy";
      lgit = "lazygit";
      k = "kubectl";
      tf = "terraform";
      # programs.lsd の zsh integration も ls を定義するため優先度で上書きする
      ls = lib.mkForce "eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions";
      cd = "z";
    };

    envExtra = ''
      ### XDG ###
      # References: https://wiki.archlinux.jp/index.php/XDG_Base_Directory
      export XDG_CONFIG_HOME="$HOME/.config"
      export XDG_DATA_HOME="$HOME/.local/share"
      export XDG_STATE_HOME="$HOME/.local/state"
      export XDG_CACHE_HOME="$HOME/.cache"

      export EDITOR=nvim
      export GPG_TTY=$(tty)
      # エラーメッセージやツールの表示を英語にし、エンコードを UTF-8 に固定する
      export LANG="en_US.UTF-8"

      # /etc/zprofile, /etc/zshrc などシステム側の設定は読まない
      unsetopt GLOBAL_RCS

      export GOPATH="$XDG_DATA_HOME/go"
      export DENO_INSTALL="$XDG_DATA_HOME/deno"
      export DENO_INSTALL_ROOT="$DENO_INSTALL"
      export SHELDON_CONFIG_DIR="$ZDOTDIR"
      export BUN_INSTALL="$HOME/.bun"
    '';

    # path を丸ごと再定義するため、home.sessionPath と nix-darwin 由来の既存 path を
    # 明示的に残す (以前は aqua の bin が PATH から落ちていた)
    profileExtra = ''
      typeset -U path
      path=(
        ${lib.concatMapStringsSep "\n  " (p: ''"${p}"'') config.home.sessionPath}
        "$HOME/.local/bin"
        "/opt/homebrew/bin"
        "$HOME/go/bin"
        "$DENO_INSTALL_ROOT/bin"
        "$DENO_INSTALL_ROOT/env"
        "$HOME/.cargo/env"
        "/Applications/kitty.app/Contents/MacOS"
        "$HOME/apache-maven-3.9.2/bin"
        /usr/bin
        /bin
        /usr/sbin
        /sbin
        /usr/local/bin
        /usr/local/cuda/bin
        "$GOPATH/bin"
        /opt/local/bin
        /opt/local/sbin
        "$HOME/.bun/bin"
        $path
      )
      export PATH

      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    initContent = lib.mkMerge [
      # .zprofile で path を再定義しているため、nix のプロファイルを最優先に戻す
      (lib.mkOrder 500 ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          unset __ETC_PROFILE_NIX_SOURCED
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '')

      ''
        bindkey -s ^k "tmux-sessionizer\n"
        bindkey -s ^q "tmux-sessionizer list\n"

        setopt AUTO_PUSHD
        setopt PUSHD_IGNORE_DUPS
        setopt GLOBDOTS
        setopt INC_APPEND_HISTORY
        setopt HIST_REDUCE_BLANKS
        setopt INTERACTIVE_COMMENTS
        setopt NO_BEEP
        setopt NO_FLOW_CONTROL
        setopt NO_CLOBBER
        setopt HIST_NO_STORE

        # 移動系や削除系のコマンドは履歴に残さない
        zshaddhistory() {
          local line="''${1%%$'\n'}"
          [[ ! "$line" =~ "^(cd|jj?|lazygit|la|ll|ls|rm|rmdir)($| )" ]]
        }

        git-change() {
          command git checkout $(git branch --all | fzf)
        }

        _fzf_compgen_path() {
          fd --hidden --exclude .git . "$1"
        }

        _fzf_compgen_dir() {
          fd --type=d --hidden --exclude .git . "$1"
        }

        _fzf_comprun() {
          local command=$1
          shift

          case "$command" in
            cd)           fzf --preview '${dirPreview}' "$@" ;;
            export|unset) fzf --preview "eval 'echo \''${}'"         "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview '${fileOrDirPreview}' "$@" ;;
          esac
        }

        source ${fzf-git}/fzf-git.sh

        dev-root() {
          local selected
          selected="$(
            {
              ghq list -p 2>/dev/null
              # worktrees は host/org/repo/branch の固定4階層なので深さを制限し node_modules 等への降下を防ぐ
              fd -H -t f -d 5 '^\.git$' "''${HOME}/worktrees" 2>/dev/null | sed 's|/\.git$|/|'
              fd -t d -d 1 . "''${HOME}/.config" 2>/dev/null
            } | sed "s|^''${HOME}|~|" | fzf
          )" || return
          [ -n "''${selected}" ] && cd "''${selected/#\~/''${HOME}}"
        }
        bindkey -s ^d "dev-root\n"

        [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
      ''
    ];
  };

  programs.fzf = {
    defaultCommand = fdHidden;
    fileWidget.command = fdHidden;
    fileWidget.options = [ "--preview '${fileOrDirPreview}'" ];
    changeDirWidget.command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidget.options = [ "--preview '${dirPreview}'" ];
  };

  # Claude Code の hooks から ~/.config/zsh/claude-notify.sh として呼ばれる
  xdg.configFile."zsh/claude-notify.sh".source = ../../../zsh/claude-notify.sh;
}
