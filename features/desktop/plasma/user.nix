{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
    libnotify
    krita
    kdePackages.filelight
    unrar
  ];
}
