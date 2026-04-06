{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Educational
    gcompris      # 100+ educational activities
    tuxtype       # Typing tutor
    tuxpaint      # Award-winning drawing program for kids
    kdePackages.kanagram      # Anagram puzzle game

    # Casual/Kid-Friendly Gaming
    supertuxkart  # Mario Kart alternative
    supertux      # Super Mario alternative
  ];
}
