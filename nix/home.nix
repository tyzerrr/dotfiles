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
  ];
}
