# personal マシン (araki) 固有の nix-darwin 設定
{
  homebrew = {
    taps = [ "felixkratz/formulae" ];
    brews = [
      "felixkratz/formulae/borders"
      "gcc"
      "ruby-build"
      # sudo での postinstall と launchd デーモン登録が必要な brew 専用の仕組み
      "socket_vmnet"
    ];
    casks = [
      # nixpkgs の texlive scheme-full は 5GB 超で store 側に重複するため Homebrew のまま
      "mactex"
      # Apple の Developer Portal 配布限定で nixpkgs に存在しない
      "sf-symbols"
    ];
  };

  # 2026-11 時点で明示的に設定されていた値をそのまま宣言している
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 47;
      orientation = "left";
      show-recents = false;
    };
    finder.FXPreferredViewStyle = "clmv";
    trackpad.Clicking = false;
    screencapture.location = "~/Documents/";
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      _HIHideMenuBar = false;
      NSAutomaticCapitalizationEnabled = true;
      AppleKeyboardUIMode = 3;
    };
  };
}
