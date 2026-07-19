{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    heroic
    gopher64
    protonup-qt
    mangohud
    eden
    retroarch
    dolphin-emu
  ];
}
