{ pkgs, ... }:
{
  home.username = "t-b-araki";
  home.homeDirectory = "/Users/t-b-araki";
  home.stateVersion = "25.11";

  # home-manager
  programs.home-manager.enable = true;

  # zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # bat
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      pager = "less -FR";
    };
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
    fzf
    tmux
    ghq
    eza
    vim
    neovim
    awscli2
    gh
    golangci-lint
    kubernetes-helm
    minikube
    kustomize
    lazygit
    lsd
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
    direnv
  ];
}
