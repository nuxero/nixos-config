# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-index-database.nixosModules.nix-index

      # System-level features
      ../../features/hardware/bluetooth/system.nix
      ../../features/desktop/plasma/system.nix
      ../../features/desktop/plymouth/system.nix
      ../../features/apps/audio-production/system.nix
      ../../features/apps/work-dev/system.nix
      (import ../../features/apps/automated-qa/system.nix {
        qaUsers = [ "erika" ];
      })
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Automated Maintenance
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };
  nix.settings.auto-optimise-store = true;

  networking.hostName = "dell-laptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/El_Salvador";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_MX.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_SV.UTF-8";
    LC_IDENTIFICATION = "es_SV.UTF-8";
    LC_MEASUREMENT = "es_SV.UTF-8";
    LC_MONETARY = "es_SV.UTF-8";
    LC_NAME = "es_SV.UTF-8";
    LC_NUMERIC = "es_SV.UTF-8";
    LC_PAPER = "es_SV.UTF-8";
    LC_TELEPHONE = "es_SV.UTF-8";
    LC_TIME = "es_SV.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.hector = {
    isNormalUser = true;
    description = "Hector Zelaya";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
  };

  users.users.erika = {
    isNormalUser = true;
    description = "Erika Cubias";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hector = {
      imports = [
        ../../features/desktop/plasma/user.nix
        ../../features/apps/audio-production/user.nix
        (import ../../features/apps/work-dev/user.nix {
          gitUserName  = "Hector Zelaya";
          gitUserEmail = "inge.zelaya@gmail.com";
        })
        ../../features/apps/kids/user.nix
      ];
      home.sessionVariables.NH_FLAKE = "/home/hector/nixos-config";
      home.stateVersion = "25.11";
    };
    users.erika = {
      imports = [
        ../../features/desktop/plasma/user.nix
        (import ../../features/apps/work-dev/user.nix {
          gitUserName  = "Erika Cubias";
          gitUserEmail = "erilis@gmail.com";
        })
        ../../features/apps/automated-qa/user.nix
        ../../features/apps/kids/user.nix
      ];
      home.sessionVariables.NH_FLAKE = "/home/erika/nixos-config";
      home.stateVersion = "25.11";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
