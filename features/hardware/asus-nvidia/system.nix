{ config, pkgs, ... }:

{
  # Overrides / additions on top of nixos-hardware ga402x-nvidia module
  # The module already sets: asusd, supergfxd, PRIME offload, bus IDs,
  # modesetting, nouveau blacklist, videoDrivers, and kernel quirks.

  # Dynamic Boost (nvidia-powerd) is disabled — the service hangs during
  # activation on the GA402X because the old process becomes unkillable
  # (stuck in a kernel driver call) and blocks multi-user.target for ~6 min.
  # See: https://discourse.nixos.org/t/nvidia-powerd-service-fails-no-matter-what-i-try/54640
  hardware.nvidia.dynamicBoost.enable = false;

  # DO NOT enable powerManagement — the nixos-hardware module explicitly
  # warns this is unreliable on the RTX 4060 Mobile and causes kernel
  # module deadlocks during suspend/resume.
  # See: https://github.com/NixOS/nixpkgs/issues/254614
  # hardware.nvidia.powerManagement.enable = true;

  # Proprietary kernel modules — the open modules (595.58.03) have a GSP firmware
  # heartbeat bug that causes timeouts on every boot and can deadlock module loading.
  # See: https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1064
  # Revisit when a driver version ships a fix for the GC6-exit heartbeat path.
  hardware.nvidia.open = false;

  # Battery-saver boot specialisation: boots with dGPU fully disabled (iGPU only).
  # Select in systemd-boot menu → "NixOS (battery-saver)"
  hardware.nvidia.primeBatterySaverSpecialisation = true;

  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;
}
