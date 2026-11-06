{
  programs.ghostty = {
    enable = true;
    # 本体は darwin.nix の Homebrew cask で入れているので設定だけ管理する
    package = null;
    settings = {
      cursor-style = "block";
      cursor-style-blink = false;
      cursor-color = "47ff9c";
      cursor-text = "011423";
      theme = "One Half Dark";
      foreground = "#f8f8f2";
      window-padding-x = 20;
      window-padding-y = 5;
      window-padding-balance = true;
      window-theme = "ghostty";
      background-opacity = 0.95;
      background-blur = false;
      macos-titlebar-style = "transparent";
      confirm-close-surface = false;
      font-feature = "-dlig";
      keybind = [ "shift+enter=text:\\x1b\\r" ];
    };
  };
}
