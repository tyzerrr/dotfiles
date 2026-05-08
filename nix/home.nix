{ pkgs, ... }:
{
  home.username = "t-b-araki";
  home.homeDirectory = "/Users/t-b-araki";
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

  home.packages = with pkgs; [
    nodejs_24
    tree-sitter
    pnpm
    terraform
    ripgrep
    go_1_26
    fd
    jq
    tmux
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
  ];
}
