{ config, pkgs, ... }:

{
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # KDE Connect — phone ↔ desktop integration
  programs.kdeconnect.enable = true;  # installs package + opens firewall ports 1714-1764

  # Partition Manager — needs system-level install for polkit action registration
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
  ];
}
