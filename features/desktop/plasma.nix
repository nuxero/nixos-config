{ config, pkgs, ...}:

{
    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    home-manager.users.hector.home.packages = with pkgs; [
        wl-clipboard
        libnotify
        gimp
    ];
}