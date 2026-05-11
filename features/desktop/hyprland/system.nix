{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────────────────────
  # Hyprland specialisation — battery-optimized tiling Wayland session
  #
  # This is designed to be used as a NixOS specialisation that REPLACES Plasma.
  # It disables SDDM/Plasma and boots directly into Hyprland via greetd.
  #
  # Usage in host configuration.nix:
  #   specialisation.hyprland.configuration = {
  #     imports = [ ../../features/desktop/hyprland/system.nix ];
  #   };
  # ──────────────────────────────────────────────────────────────────────────────

  # Tag for identification in boot menu
  system.nixos.tags = [ "hyprland" ];

  # ── Disable Plasma/SDDM ────────────────────────────────────────────────────
  services.displayManager.sddm.enable = lib.mkForce false;
  services.desktopManager.plasma6.enable = lib.mkForce false;
  programs.kdeconnect.enable = lib.mkForce false;

  # ── Enable Hyprland compositor ──────────────────────────────────────────────
  programs.hyprland.enable = true;

  # ── Greeter: greetd + tuigreet (minimal, fast, no GPU overhead) ─────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # ── XDG Desktop Portal (screen sharing, file picker) ────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk  # file picker fallback
    ];
  };

  # ── System packages needed for the Hyprland session ─────────────────────────
  environment.systemPackages = with pkgs; [
    brightnessctl        # backlight control (bound to hardware keys)
    playerctl            # MPRIS media key control
    networkmanagerapplet # nm-applet for WiFi tray
  ];

  # ── SwayOSD: install udev rules so brightness/volume OSD works without the warning ─
  services.udev.packages = [ pkgs.swayosd ];

  # ── Security: polkit agent (needed for privileged actions) ──────────────────
  security.polkit.enable = true;

  # ── PAM: unlock gnome-keyring on login (for WiFi passwords, etc.) ───────────
  security.pam.services.greetd.enableGnomeKeyring = true;

  # ── Gnome Keyring: needed for Slack, Chrome, etc. to persist auth tokens ────
  services.gnome.gnome-keyring.enable = true;
}
