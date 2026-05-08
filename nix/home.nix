{ pkgs, ... }:
{
  home.username = "araki";
  home.homeDirectory = "/Users/araki";
  home.stateVersion = "25.11";
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
    bat
    eza
    zoxide
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
