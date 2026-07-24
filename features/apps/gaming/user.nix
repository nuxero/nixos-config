{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    heroic
    #protonup-qt
    #mangohud
    eden
    retroarch-full
  ];
}
