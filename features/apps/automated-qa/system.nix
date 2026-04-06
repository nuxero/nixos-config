{ qaUsers }:

{ config, pkgs, ... }:

{
  # ADB + udev rules for Android device access (Appium mobile testing)
  # Add "adbusers" to each user's extraGroups in the host configuration
  programs.adb.enable = true;

  # Grant specified users unprivileged access to Android devices
  users.groups.adbusers.members = qaUsers;
}
