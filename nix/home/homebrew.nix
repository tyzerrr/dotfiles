{ pkgs, ... }:
{
  # brew が tap 由来の formula を信頼済みとして扱うためのリスト
  xdg.configFile."homebrew/trust.json".source = (pkgs.formats.json { }).generate "homebrew-trust" {
    trustedformulae = [ "kouzoh/tap/merctl" ];
  };
}
