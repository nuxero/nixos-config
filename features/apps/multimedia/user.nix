{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    exaile
    vlc
    yt-dlp
    shotcut
  ];

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
    ];
  };
}
