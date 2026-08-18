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

  # OmniWM 0.6.0 can leave the focus border waiting for a mouse click after
  # a workspace switch. Keep the small IPC workaround running per-user.
  launchd.user.agents.omniwm-border-refresh = {
    script = "/Users/${username}/.config/omniwm/refresh-border.sh --watch";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      ThrottleInterval = 5;
      StandardOutPath = "/tmp/omniwm-border-refresh.log";
      StandardErrorPath = "/tmp/omniwm-border-refresh.log";
    };
  };

  # nix-darwin の互換バージョン。基本変更しない
  system.stateVersion = 6;
}
