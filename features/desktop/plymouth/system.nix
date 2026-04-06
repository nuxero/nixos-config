{ config, pkgs, ... }:

{
  # Enable Plymouth
  boot.plymouth = {
    enable = true;
    # "bgrt" is the modern standard. It keeps your manufacturer's 
    # OEM logo (Asus/Dell) and puts a spinning loading circle below it.
    theme = "bgrt"; 
  };

  # Make the boot process completely silent so the splash screen displays cleanly
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  
  # Hide the kernel text logs
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
}
