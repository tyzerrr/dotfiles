{ pkgs, username, homeDirectory, ... }:
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  #home-manager
  programs.home-manager.enable = true;

  #zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  #bat
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      pager = "less -FR";
    };
  };

  #direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  #fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  #eza
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
    git = true;
  };

  #gh
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  #lazygit
  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  #lsd
  programs.lsd = {
    enable = true;
    enableZshIntegration = true;
  };

  #git
  programs.git = {
    enable = true;

    signing = {
      key = "28D3AABC18605362F8975AFA7B5A5A50B3388C95";
      signByDefault = true;
    };

    ignores = [
      "**/.claude/settings.local.json"
    ];

    settings = {
      user = {
        name  = "Taichi Araki";
        email = "t-b-araki@mercari.com";
      };
      init.defaultBranch = "main";
      url."git@github.com:".insteadOf = "https://github.com/";
      gpg.program = "${pkgs.gnupg}/bin/gpg";
      # credential helper は programs.gh.enable が自動で追加するので不要
    };
  };

  #gpg
  programs.gpg.enable = true;

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
  '';

  home.file.".gnupg/common.conf".text = ''
    use-keyboxd
  '';

  #tmux
  programs.tmux = {
    enable = true;
    prefix = "C-g";
    mouse = true;
    keyMode = "vi";
    terminal = "xterm-ghostty";
    baseIndex = 1;
    historyLimit = 10000;

    extraConfig = ''
      # set.tmux: HM オプション無いやつ
      set -g renumber-windows on
      set -g set-clipboard on
      set -ag terminal-overrides ",xterm-ghostty:Tc"

      # remap.tmux
      bind-key c copy-mode

      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

      bind-key \\ split-window -h
      bind-key - split-window -v

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      bind-key w new-window
      bind-key s choose-window

      bind-key 0 select-window -t :0
      bind-key 1 select-window -t :1
      bind-key 2 select-window -t :2
      bind-key 3 select-window -t :3
      bind-key 4 select-window -t :4
      bind-key 5 select-window -t :5
      bind-key 6 select-window -t :6
      bind-key 7 select-window -t :7
      bind-key 8 select-window -t :8
      bind-key 9 select-window -t :9

      bind-key d detach-client

      # statusbar.tmux: Tokyo Night テーマ
      set -g status-position bottom
      set -g status-style "bg=#24283b,fg=#c0caf5"
      set -g status-justify absolute-centre

      set -g status-left-length 40
      set -g status-left "#[fg=#7aa2f7,bold]session: #(~/.config/tmux/scripts/compress_path.sh '#{session_name}') "

      set -g status-right ""

      set -g window-status-format "#[fg=#565f89] #I:#W "
      set -g window-status-current-format "#[fg=#7aa2f7,bold] #I:#W "
      set -g window-status-separator ""

      set -g pane-border-style "fg=#565f89"
      set -g pane-active-border-style "fg=#7aa2f7"

      set -g message-style "bg=default,fg=#c0caf5"
    '';
  };

  home.packages = with pkgs; [
    nodejs_24
    tree-sitter
    pnpm
    terraform
    ripgrep
    go_1_26
    fd
    jq
    ghq
    vim
    neovim
    awscli2
    golangci-lint
    kubernetes-helm
    minikube
    kustomize
    kind
    docker-client
    tflint
    kubectx
    uv
    ruff
    ssm-session-manager-plugin
    stylua
    deno
    google-cloud-sdk
    python313
    claude-code
    rustc
    cargo
    yq-go
    pinentry_mac
    pandoc
    supabase-cli
  ];
}
