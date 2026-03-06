{ pkgs, ... }:

{
  home.username = "panks";
  home.homeDirectory = "/home/panks";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [ ];
}
