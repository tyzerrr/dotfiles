{ pkgs, ... }:
{
  home.username = "araki";
  home.homeDirectory = "/Users/araki";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    nodejs_24
  ];
}
