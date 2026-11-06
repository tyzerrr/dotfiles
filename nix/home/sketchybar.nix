{
  # プラグインはシェルスクリプトのまま store に置き、ディレクトリごと配置する。
  # 自動起動は無効化しているので service は有効にしない
  xdg.configFile."sketchybar" = {
    source = ../../sketchybar;
    recursive = true;
  };
}
