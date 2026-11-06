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
}
