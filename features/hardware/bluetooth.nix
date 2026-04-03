{ config, pkgs, ... }:

{
  # Enable the Bluetooth daemon
  hardware.bluetooth.enable = true;
  
  # Power up the default Bluetooth controller on boot
  hardware.bluetooth.powerOnBoot = true;
  
  # Optional: Enables support for modern Xbox/PlayStation controllers over Bluetooth
  # hardware.bluetooth.settings = {
  #   General = {
  #     Experimental = true;
  #   };
  # };
}