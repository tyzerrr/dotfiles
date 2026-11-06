{ config, dotfilesDir, ... }:
{
  # Karabiner-Elements は GUI から karabiner.json を書き換え、ファイル単体の
  # symlink だと置き換えてしまうため、公式の推奨どおりディレクトリごとリンクする
  # https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/
  xdg.configFile."karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/karabiner";
}
