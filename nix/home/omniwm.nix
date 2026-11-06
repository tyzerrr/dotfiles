{ config, dotfilesDir, ... }:
{
  # OmniWM は設定画面 (Monitor Setup など) から settings.toml を書き換えるため、
  # read-only な store ではなく repo 内のファイルを直接リンクする
  xdg.configFile."omniwm/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/omniwm/settings.toml";
}
