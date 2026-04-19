{ config, pkgs, ... }:

{
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.gutenprintBin
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
}
