{ config, pkgs, ... }:

{
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  home-manager.users.hector.home.packages = with pkgs; [
    heroic
    gopher64
    protonup-qt 
    mangohud
    antimicrox
  ];
}