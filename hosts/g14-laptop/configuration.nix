{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # nixos-hardware: ASUS ROG Zephyrus G14 (2023, GA402X) — includes NVIDIA PRIME offload
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia

    # Shared base
    ../../features/common/system.nix

    # System-level features
    ../../features/hardware/asus-nvidia/system.nix
    ../../features/hardware/bluetooth/system.nix
    ../../features/hardware/printing/system.nix
    ../../features/desktop/plasma/system.nix
    ../../features/desktop/plymouth/system.nix
    ../../features/apps/audio-production/system.nix
    ../../features/apps/gaming/system.nix
    ../../features/apps/work-dev/system.nix
    ../../features/apps/webdav/system.nix
  ];

  # Latest kernel — recommended for ASUS ROG hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Disable PSR — prevents DMCUB errors and pageflip timeouts on Phoenix iGPU
  # i8042 params — fix intermittent keyboard dead on cold boot (known ASUS EC issue)
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
    "i8042.reset"
    "i8042.nomux"
    "i8042.nopnp"
    "i8042.noloop"
  ];

  networking.hostName = "g14-laptop";

  # v4l2-ctl, used by the webcam udev rule below
  environment.systemPackages = [ pkgs.v4l-utils ];

  # Allow non-root access to NVIDIA USB devices (e.g. Switch RCM mode)
  #
  # External XIFT Web Camera (6210:e904). Only autofocus is changed: continuous
  # autofocus is turned off and focus fixed at desk distance (focus_absolute
  # 0..1023, higher = closer). Everything else stays on firmware defaults
  # (auto-exposure, auto white balance, 50 Hz anti-flicker) so the image
  # follows daylight changes.
  #
  # What we learned:
  #   - The "heartbeat" pulsing was continuous autofocus hunting; bright window
  #     light confuses it.
  #   - The firmware defaults the anti-flicker filter to 50 Hz, but El Salvador
  #     mains is 60 Hz. If light-source blinking appears under room lights, add
  #     power_line_frequency=2 (60 Hz) so auto-exposure picks flicker-safe steps.
  #   - The camera DOES have auto-exposure: it powers up with auto_exposure=0
  #     (auto). The driver refuses to switch back to auto once set to Manual
  #     (1), so never set auto_exposure here; restoring auto needs a replug or
  #     a USB reset (echo 0, then 1, to /sys/bus/usb/devices/<port>/authorized).
  #   - Manual exposure stops the blinking but is a poor fit: a fixed value
  #     gets too dark as window daylight changes during the day.
  #
  # If problems come back, append to --set-ctrl:
  #   - image looks soft: adjust focus_absolute (lower = farther).
  #   - color tint shifting: add white_balance_automatic=0,white_balance_temperature=4
  #     (range is only 1..5, NOT Kelvin).
  #   - Last resort for light-source blinking: auto_exposure=1,exposure_time_absolute=83
  #     (83 = one 8.33 ms 60 Hz half-cycle in 100 us units; multiples 167/250/333),
  #     plus gain to brighten. This gives up auto brightness.
  # Order matters: disable an auto control before setting its manual value.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666"
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="6210", ATTRS{idProduct}=="e904", RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl focus_automatic_continuous=0,focus_absolute=150"
  '';

  # 1Password polkit access
  custom.work-dev.polkitOwners = [ "hector" ];
  # Docker users
  custom.work-dev.dockerUsers = [ "hector" ];

  users.users.hector = {
    isNormalUser = true;
    description = "Hector Zelaya";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "scanner" "lp" ];
  };

  home-manager.users.hector = {
    imports = [
      ../../features/desktop/plasma/user.nix
      ../../features/apps/audio-production/user.nix
      ../../features/apps/gaming/user.nix
      ../../features/apps/work-dev/user.nix
      ../../features/apps/cli/user.nix
      ../../features/apps/multimedia/user.nix
    ];
    custom.cli = {
      gitUserName = "Hector Zelaya";
      gitUserEmail = "hector@hectorzelaya.dev";
    };
    home.sessionVariables.NH_FLAKE = "/home/hector/nixos-config";
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
