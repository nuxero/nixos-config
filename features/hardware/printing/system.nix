{ config, pkgs, ... }:

{
  # CUPS printing with Canon PIXMA G-series drivers
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];

  # Scanner support (SANE + driverless eSCL/AirScan)
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];
}
