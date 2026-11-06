{ lib, ... }:
let
  options = {
    style = "round";
    width = "10.0";
    hidpi = "on";
    active_color = "0xFF7aa2f7";
    inactive_color = "0xaa595959";
  };
in
{
  # JankyBorders は起動時に bordersrc を実行して自身にオプションを渡す。
  # 自動起動は無効化しているので service ではなく設定ファイルだけ置く
  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/bash
      options=(
        ${lib.concatStringsSep "\n  " (lib.mapAttrsToList (k: v: "${k}=${v}") options)}
      )

      borders "''${options[@]}"
    '';
  };
}
