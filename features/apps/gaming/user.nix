{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    heroic
    gopher64
    protonup-qt
    mangohud
    # these require US roms to be added to nix-store
    # nix-store --add-fixed sha256 ~/path/to/rom.z64
    # lowPrio/hiPrio to avoid shared asset collisions between recomp packages
    (lib.hiPrio mariokart64recomp)  # mk64.us.z64
    starfox64recomp                 # starfox64.us.rev1.z64
    (lib.lowPrio zelda64recomp)     # mm.us.rev1.rom.z64
  ];
}
