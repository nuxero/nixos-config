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
  # External XIFT Web Camera (6210:e904): the rhythmic blink is mains/light
  # flicker (rolling shutter beating against 60 Hz AC lighting), NOT autofocus
  # and NOT auto-exposure hunting — this camera's firmware only exposes
  # auto_exposure=1 (Manual Mode), so there is no auto mode to hunt. The fix is
  # to match the anti-flicker frequency and pick an exposure that is a whole
  # multiple of the mains half-cycle:
  #   - power_line_frequency=2 (60 Hz — El Salvador mains)  anti-flicker filter
  #   - auto_exposure=1 (Manual) + exposure_time_absolute=250  (= 3x 8.33 ms
  #     half-cycle at 60 Hz, in 100 us UVC units; avoids banding/pulsing while
  #     letting in enough light. Keep this a multiple of 83: 83/167/250/333...)
  #   - gain=64  (brightens the fixed-exposure image without reintroducing
  #     flicker; higher adds noise)
  #   - focus_automatic_continuous=0 + focus_absolute=150  (sharp at desk distance)
  #   - white_balance_automatic=0 + white_balance_temperature=4  (this device's
  #     white_balance_temperature range is only 1..5, NOT Kelvin)
  # Control order matters: auto_exposure must switch to Manual before
  # exposure_time_absolute becomes writable, and likewise for white balance.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666"
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="6210", ATTRS{idProduct}=="e904", RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl power_line_frequency=2,focus_automatic_continuous=0,focus_absolute=150,auto_exposure=1,exposure_time_absolute=250,gain=64,white_balance_automatic=0,white_balance_temperature=4"
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
