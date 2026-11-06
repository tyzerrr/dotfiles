{ config, dotfilesDir, ... }:
{
  # Lua の設定は Nix 化しない。lazy.nvim が lazy-lock.json を書き換え、編集も
  # switch なしで即反映したいので repo を直接リンクする
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/nvim";
}
