{ config, dotfilesDir, ... }:
{
  # kitten (Python) を含み、`kitten themes` や id_history.py が current-theme.conf /
  # last_window_id.txt を書き換えるため、Nix 化せず repo を直接リンクする
  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/kitty";
}
