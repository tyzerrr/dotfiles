{
  # 設定本体は Lua (require で分割) なので、ディレクトリごと store から配置する。
  # programs.wezterm は wezterm.lua を生成して衝突するため使わない
  xdg.configFile."wezterm" = {
    source = ../../wezterm;
    recursive = true;
  };
}
