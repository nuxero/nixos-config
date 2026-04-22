{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-amdgpu

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
    ../../features/debug/system.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-5c82c1ce-a9e8-4502-a767-baa1834b7b71".device = "/dev/disk/by-uuid/5c82c1ce-a9e8-4502-a767-baa1834b7b71";

  # TEMPORARILY DISABLED: Samsung NVMe controller crashes (CSTS=0x3) may be triggered by TRIM.
  # Re-enable once pcie_aspm.policy=performance is confirmed to fix the controller crashes.
  # boot.initrd.luks.devices."luks-372ebe08-549c-43f5-8c14-3181293a1380".allowDiscards = true;
  # services.fstrim.enable = true;

  networking.hostName = "g14-laptop";

  # 1Password polkit access
  custom.work-dev.polkitOwners = [ "hector" ];

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

  system.stateVersion = "25.11";
}
