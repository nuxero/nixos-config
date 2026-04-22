{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Work & Cloud
    maestral
    maestral-gui
    slack
    google-chrome
    dbeaver-bin
    awscli2
    git
    kiro
    kiro-cli
    sweethome3d.application
  ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };

  # Autostart Maestral via XDG (Plasma picks this up natively)
  xdg.configFile."autostart/maestral-gui.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Maestral
    Exec=${pkgs.bash}/bin/bash -c "sleep 5 && ${pkgs.maestral-gui}/bin/maestral_qt"
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';
}
