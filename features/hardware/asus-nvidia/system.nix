{ config, pkgs, ... }:

{
  # Overrides / additions on top of nixos-hardware ga402x-nvidia module
  # The module already sets: asusd, supergfxd, PRIME offload, bus IDs,
  # modesetting, nouveau blacklist, videoDrivers, and kernel quirks.

  hardware.nvidia.dynamicBoost.enable = true;  # enables nvidia-powerd — supergfxd expects this service
  hardware.nvidia.powerManagement.enable = true;

  # Proprietary kernel modules — the open modules (595.58.03) have a GSP firmware
  # heartbeat bug that causes timeouts on every boot and can deadlock module loading.
  # See: https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1064
  # Revisit when a driver version ships a fix for the GC6-exit heartbeat path.
  hardware.nvidia.open = false;

  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;
}
