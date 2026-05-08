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
  # UCSI Alt Mode handshake.  Reloading ucsi_acpi after the display manager is
  # up forces a clean re-negotiation so the external display is detected without
  # a manual replug.
  # See: https://gist.github.com/gornostal/ec270bf2d5a4380ed556c4a6011df149
  systemd.services.usbc-dp-workaround = {
    description = "Reload UCSI to fix USB-C DisplayPort Alt Mode detection";
    after = [ "display-manager.service" ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.kmod}/bin/modprobe -r ucsi_acpi typec_ucsi && sleep 1 && ${pkgs.kmod}/bin/modprobe ucsi_acpi typec_ucsi'";
      RemainAfterExit = true;
    };
  };

  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;
}
