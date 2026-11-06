{ lib, pkgs, ... }:
let
  workspaces = map toString (lib.range 1 9);
  forWorkspaces = f: lib.listToAttrs (map f workspaces);

  # アプリごとの初期 workspace。app-id は `aerospace list-apps` で確認できる
  appWorkspaces = [
    { app-id = "com.tinyspeck.slackmacgap"; workspace = "2"; } # Slack
    { app-id = "com.google.Chrome"; workspace = "3"; } # メインブラウザ
    { app-id = "com.github.wez.wezterm"; workspace = "4"; }
    { app-id = "com.jetbrains.goland"; workspace = "5"; }
    { app-id = "com.anthropic.claudefordesktop"; workspace = "6"; }
    { app-id = "com.todesktop.230313mzl4w4u92"; workspace = "7"; } # Cursor
    { app-id = "notion.id"; workspace = "8"; }
  ];
in
{
  programs.aerospace = {
    enable = true;
    package = pkgs.aerospace;
    # home-manager モジュールは start-at-login を常に false にするため、ログイン時の
    # 起動は launchd に任せる。OmniWM と切り替えて試せるよう落ちても再起動はしない
    launchd = {
      enable = true;
      keepAlive = false;
    };

    settings = {
      # sketchybar / borders はここで起動しない（自動起動を無効化したため）
      after-startup-command = [ ];

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = false;

      key-mapping.preset = "qwerty";

      gaps = {
        inner.horizontal = 10;
        inner.vertical = 10;
        outer.left = 10;
        outer.bottom = 10;
        outer.top = 10;
        outer.right = 10;
      };

      mode.main.binding = {
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";
        alt-shift-f = "fullscreen";

        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        alt-shift-semicolon = "mode service";
      }
      // forWorkspaces (n: lib.nameValuePair "alt-${n}" "workspace ${n}")
      // forWorkspaces (n: lib.nameValuePair "alt-shift-${n}" "move-node-to-workspace ${n}");

      mode.service.binding = {
        esc = [ "reload-config" "mode main" ];
        r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
        f = [ "layout floating tiling" "mode main" ]; # floating と tiling の切り替え
        backspace = [ "close-all-windows-but-current" "mode main" ];
        alt-shift-h = [ "join-with left" "mode main" ];
        alt-shift-j = [ "join-with down" "mode main" ];
        alt-shift-k = [ "join-with up" "mode main" ];
        alt-shift-l = [ "join-with right" "mode main" ];
        down = "volume down";
        up = "volume up";
        shift-down = [ "volume set 0" "mode main" ];
      };

      on-window-detected = [
        # macOS ネイティブタブの問題を避けるため Ghostty は常に tiling にする
        # https://github.com/nikitabobko/AeroSpace/issues/778
        {
          "if".app-id = "com.mitchellh.ghostty";
          run = [ "layout tiling" ];
        }
      ]
      ++ map (a: {
        "if".app-id = a.app-id;
        run = "move-node-to-workspace ${a.workspace}";
      }) appWorkspaces;

      workspace-to-monitor-force-assignment = forWorkspaces (
        n: lib.nameValuePair n (if lib.toInt n <= 7 then "main" else "secondary")
      );
    };
  };
}
