{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Shared base
    ../../features/common/system.nix

    # System-level features
    ../../features/hardware/bluetooth/system.nix
    ../../features/hardware/printing/system.nix
    ../../features/desktop/plasma/system.nix
    ../../features/desktop/plymouth/system.nix
    ../../features/apps/audio-production/system.nix
    ../../features/apps/work-dev/system.nix
  ];

  # Override: Spanish locale for this machine
  i18n.defaultLocale = "es_MX.UTF-8";

  networking.hostName = "dell-laptop";

  # 1Password polkit access
  custom.work-dev.polkitOwners = [ "hector" "erika" ];

  users.users.hector = {
    isNormalUser = true;
    description = "Hector Zelaya";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "scanner" "lp" ];
  };

  users.users.erika = {
    isNormalUser = true;
    description = "Erika Cubias";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "scanner" "lp" ];
  };

  home-manager.users.hector = {
    imports = [
      ../../features/desktop/plasma/user.nix
      ../../features/apps/audio-production/user.nix
      ../../features/apps/work-dev/user.nix
      ../../features/apps/cli/user.nix
      ../../features/apps/multimedia/user.nix
      ../../features/apps/kids/user.nix
    ];
    custom.cli = {
      gitUserName = "Hector Zelaya";
      gitUserEmail = "inge.zelaya@gmail.com";
    };
    home.sessionVariables.NH_FLAKE = "/home/hector/nixos-config";
    home.stateVersion = "25.11";
  };

  home-manager.users.erika = {
    imports = [
      ../../features/desktop/plasma/user.nix
      ../../features/apps/work-dev/user.nix
      ../../features/apps/cli/user.nix
      ../../features/apps/automated-qa/user.nix
      ../../features/apps/kids/user.nix
    ];
    custom.cli = {
      gitUserName = "Erika Cubias";
      gitUserEmail = "erilis@gmail.com";
    };
    home.sessionVariables.NH_FLAKE = "/home/erika/nixos-config";
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
