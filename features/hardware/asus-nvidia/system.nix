{ config, pkgs, ... }:

{
  # Overrides / additions on top of nixos-hardware ga402x-nvidia module
  # The module already sets: asusd, supergfxd, PRIME offload, bus IDs,
  # modesetting, nouveau blacklist, videoDrivers, and kernel quirks.

  hardware.nvidia.dynamicBoost.enable = true;  # enables nvidia-powerd — supergfxd expects this service

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

  # Workaround: USB-C DP Alt Mode not negotiated at boot on left port (AMD iGPU).
  # nvidia-modeset probes AMD-owned DP connectors during init and disrupts the
  # UCSI Alt Mode handshake.  After the display manager is up we force amdgpu to
  # re-probe all DP connectors, which re-triggers link training and detects the
  # external display without a manual cable replug.
  systemd.services.usbc-dp-workaround = {
    description = "Force AMD DP connector reprobe for USB-C display detection";
    after = [ "display-manager.service" ];
    requires = [ "display-manager.service" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Wait for DP link to stabilize after nvidia-modeset finishes probing,
      # then force amdgpu to re-detect all DP connectors.
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.bash}/bin/bash -c 'for conn in /sys/class/drm/card1-DP-*/status; do echo detect > \"$$conn\"; done'";
      RemainAfterExit = true;
    };
  };

  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;
}
