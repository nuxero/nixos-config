{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    heroic
    #protonup-qt
    #mangohud
    eden
    rclone # for syncing game saves from saves server
    (retroarch.withCores (cores: with cores; [
      melondsds       # Nintendo DS
      gambatte        # Game Boy / Game Boy Color
      mgba            # Game Boy Advance
      dolphin         # GameCube / Wii
      mupen64plus     # Nintendo 64 (Mupen64Plus-Next)
      snes9x          # SNES
      genesis-plus-gx # Mega Drive / Genesis
      ppsspp          # PSP
    ]))
  ];

  home.file.".config/retroarch/shaders/shaders_slang" = {
    source = "${pkgs.libretro-shaders-slang}/share/libretro/shaders/shaders_slang";
  };
}
