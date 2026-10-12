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

    # Digital Clock calendar ↔ Merkuro/Akonadi integration:
    #   - kdepim-addons provides the "PIM Events Plugin" (pimevents.so) that the
    #     clock's calendar popup reads from. Not pulled in by the plasma6 module
    #     by default because it drags in a chunk of Plasma.
    #   - akonadi-calendar is required for the events to actually render in the
    #     widget after recent Plasma/Akonadi updates (nixpkgs#344025).
    # After rebuild: right-click clock → Configure → Calendar → enable
    # "PIM Events Plugin", then enable the Merkuro calendar in the sidebar.
    kdePackages.kdepim-addons
    kdePackages.akonadi-calendar
  ];

  # NixOS-specific: expose Akonadi resource .desktop files so Merkuro can
  # register calendar sources (CalDAV/local). Without this Merkuro shows no
  # calendar sources to add (nixpkgs#344025).
  environment.pathsToLink = [ "/share/akonadi" ];
}
