{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    libnotify
    gimp
    kdePackages.filelight
  ];
}
