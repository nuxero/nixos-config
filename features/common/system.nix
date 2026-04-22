{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  nix.settings.auto-optimise-store = true;

  # Networking
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = lib.mkDefault "America/El_Salvador";

  # Locale — use lib.mkDefault so hosts can override
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
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

  # Home-manager defaults
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
