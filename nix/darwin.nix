{ pkgs, username, ... }:
let
  omniwmRefreshBorder = pkgs.replaceVarsWith {
    src = ../omniwm/refresh-border.sh;
    isExecutable = true;
    replacements = {
      omniwmctl = "${pkgs.omniwm}/bin/omniwmctl";
      jq = "${pkgs.jq}/bin/jq";
    };
  };
in
{
  # Nix 自体は Determinate Nix Installer に管理させる
  nix.enable = false;

  # nix-darwin で homebrew / ユーザー固有オプションを使うために必須
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # zsh をログインシェルとして有効化
  programs.zsh.enable = true;

  # nixpkgs に無い / brew 専用の仕組みに依存するものだけ Homebrew で管理する。
  # マシン固有のものは hosts/<username>.nix に書く。
  # cleanup = "none" なので、ここに無い既存の formula/cask は削除されない
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
    script = "${omniwmRefreshBorder} --watch";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      ThrottleInterval = 5;
      # world-writable な /tmp を避け、ユーザーのログディレクトリに出す
      StandardOutPath = "/Users/${username}/Library/Logs/omniwm-border-refresh.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/omniwm-border-refresh.log";
    };
  };

  # nix-darwin の互換バージョン。基本変更しない
  system.stateVersion = 6;
}
