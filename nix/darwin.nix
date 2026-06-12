{ username, ... }:
{
  # Nix 自体は Determinate Nix Installer に管理させる
  nix.enable = false;

  # nix-darwin で homebrew / ユーザー固有オプションを使うために必須
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # zsh をログインシェルとして有効化
  programs.zsh.enable = true;

  # GUI アプリ等は nixpkgs に無い / darwin 非対応なので Homebrew で管理
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    casks = [
      "ghostty"
    ];
  };

  # nix-darwin の互換バージョン。基本変更しない
  system.stateVersion = 6;
}
