{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeScriptBin "ghq-migrate" (builtins.readFile ../../scripts/ghq-migrate.sh))
  ];
}
