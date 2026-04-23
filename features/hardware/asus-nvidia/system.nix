{ config, pkgs, ... }:

{
  # Overrides / additions on top of nixos-hardware ga402x-nvidia module
  # The module already sets: asusd, supergfxd, PRIME offload, bus IDs,
  # modesetting, nouveau blacklist, videoDrivers, and kernel quirks.

  hardware.nvidia.dynamicBoost.enable = true;  # enables nvidia-powerd — supergfxd expects this service
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;  # supergfxd handles RTD3 PM; having both causes GSP firmware crash
  hardware.nvidia.open = true;  # open kernel modules — revisit if GSP issues persist
                                # WARNING: NVIDIA dropping proprietary modules post-580

  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.graphics.enable = true;
}
