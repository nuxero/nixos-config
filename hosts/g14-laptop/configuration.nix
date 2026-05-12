{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # nixos-hardware: ASUS ROG Zephyrus G14 (2023, GA402X) — includes NVIDIA PRIME offload
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia

    # Shared base
    ../../features/common/system.nix

    # System-level features
    ../../features/hardware/asus-nvidia/system.nix
    ../../features/hardware/bluetooth/system.nix
    ../../features/hardware/printing/system.nix
    ../../features/desktop/plasma/system.nix
    ../../features/desktop/plymouth/system.nix
    ../../features/apps/audio-production/system.nix
    ../../features/apps/gaming/system.nix
    ../../features/apps/work-dev/system.nix
  ];

  # Latest kernel — recommended for ASUS ROG hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable PSR — prevents DMCUB errors and pageflip timeouts on Phoenix iGPU
  # i8042 params — fix intermittent keyboard dead on cold boot (known ASUS EC issue)
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "i8042.reset"
    "i8042.nomux"
    "i8042.nopnp"
    "i8042.noloop"
  ];

  networking.hostName = "g14-laptop";

  # 1Password polkit access
  custom.work-dev.polkitOwners = [ "hector" ];
  # Docker users
  custom.work-dev.dockerUsers = [ "hector" ];

  users.users.hector = {
    isNormalUser = true;
    description = "Hector Zelaya";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "scanner" "lp" ];
  };

  home-manager.users.hector = {
    imports = [
      ../../features/hardware/asus-nvidia/user.nix
      ../../features/desktop/plasma/user.nix
      ../../features/apps/audio-production/user.nix
      ../../features/apps/gaming/user.nix
      ../../features/apps/work-dev/user.nix
      ../../features/apps/cli/user.nix
      ../../features/apps/multimedia/user.nix
    ];
    custom.cli = {
      gitUserName = "Hector Zelaya";
      gitUserEmail = "inge.zelaya@gmail.com";
    };
    home.sessionVariables.NH_FLAKE = "/home/hector/nixos-config";
    home.stateVersion = "25.11";
  };

  # WIP commenting for now. Having issues with shared login sessions with Slack, Chrome, Wifi. These are not being persisted in Hyprland
  # ── Specialisation: Hyprland (battery-optimized) ───────────────────────────
  # Select at boot via systemd-boot menu → "NixOS (hyprland)"
  #specialisation.hyprland.configuration = {
  #  imports = [ ../../features/desktop/hyprland/system.nix ];

    # Add Hyprland user-level config to home-manager
  #  home-manager.users.hector = {
  #    imports = [ ../../features/desktop/hyprland/user.nix ];
  #  };
  #};

  system.stateVersion = "25.11";
}
