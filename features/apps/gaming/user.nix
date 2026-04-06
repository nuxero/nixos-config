{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    heroic
    gopher64
    protonup-qt
    mangohud
  ];
}
