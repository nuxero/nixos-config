{ config, pkgs, lib, ... }:

{
  # ──────────────────────────────────────────────────────────────────────────────
  # Hyprland — Home Manager user configuration
  #
  # Battery-optimized tiling Wayland session with full desktop functionality.
  # Designed as a drop-in replacement for KDE Plasma's daily-driver features.
  # ──────────────────────────────────────────────────────────────────────────────

  # ── Hyprland compositor ─────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;  # integrate with systemd user session

    settings = {
      # ── Monitor configuration ───────────────────────────────────────────────
      # Auto-detect and arrange monitors; override per-host if needed
      monitor = [
        ",preferred,auto,1"  # fallback: any monitor at native res
      ];

      # ── Input ───────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };
        sensitivity = 0;
      };

      # ── General appearance ──────────────────────────────────────────────────
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(313244aa)";
        layout = "dwindle";
      };

      # ── Decorations (battery-conscious defaults) ────────────────────────────
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
          color = "rgba(1a1a2eee)";
        };
      };

      # ── Animations (lightweight — saves GPU cycles on battery) ──────────────
      animations = {
        enabled = true;
        bezier = [
          "ease, 0.25, 0.1, 0.25, 1.0"
          "easeOut, 0.0, 0.0, 0.2, 1.0"
        ];
        animation = [
          "windows, 1, 3, ease, slide"
          "windowsOut, 1, 3, easeOut, slide"
          "fade, 1, 3, ease"
          "workspaces, 1, 3, ease, slide"
        ];
      };

      # ── Layout ──────────────────────────────────────────────────────────────
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # ── Misc ────────────────────────────────────────────────────────────────
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;  # variable frame rate — major battery saver
      };

      # ── Autostart ───────────────────────────────────────────────────────────
      exec-once = [
        "waybar"
        "hyprpaper"
        "hypridle"
        "mako"
        "nm-applet --indicator"
        "blueman-applet"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "swayosd-server"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      # ── Key bindings ────────────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # ── App launchers ───────────────────────────────────────────────────
        "$mod, Return, exec, kitty"
        "$mod, D, exec, wofi --show drun --allow-images"
        "$mod, E, exec, dolphin"

        # ── Window management ───────────────────────────────────────────────
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 0"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, S, togglesplit"

        # ── Focus (vim-style + arrows) ──────────────────────────────────────
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"
        "$mod, Up, movefocus, u"
        "$mod, Down, movefocus, d"

        # ── Move windows ────────────────────────────────────────────────────
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # ── Workspaces ──────────────────────────────────────────────────────
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # ── Move to workspace ───────────────────────────────────────────────
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # ── Special workspace (scratchpad) ──────────────────────────────────
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"

        # ── Screenshots (grimblast) ─────────────────────────────────────────
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy output"
        "$mod, Print, exec, grimblast copy window"

        # ── Clipboard history ───────────────────────────────────────────────
        "$mod SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # ── Lock screen ─────────────────────────────────────────────────────
        "$mod, Escape, exec, hyprlock"

        # ── Power profiles toggle ───────────────────────────────────────────
        "$mod SHIFT, P, exec, powerprofilesctl launch -- bash -c 'current=$(powerprofilesctl get); case $current in performance) powerprofilesctl set balanced;; balanced) powerprofilesctl set power-saver;; *) powerprofilesctl set performance;; esac; notify-send \"Power Profile\" \"$(powerprofilesctl get)\"'"
      ];

      # ── Hardware keys (bindl = works even when locked, bindle = repeatable) ─
      bindl = [
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioStop, exec, playerctl stop"
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      # ── Mouse bindings ──────────────────────────────────────────────────────
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # ── Window rules ────────────────────────────────────────────────────────
      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "float, class:^(org.kde.dolphin)$, title:^(Progress Dialog)$"
        "float, class:^(org.kde.dolphin)$, title:^(Copying)$"
      ];
    };
  };

  # ── Waybar ──────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.target = "hyprland-session.target";

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;

        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "bluetooth"
          "power-profiles-daemon"
          "battery"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            active = "●";
            default = "○";
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        tray = {
          spacing = 8;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰅶";
            deactivated = "󰾪";
          };
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        };

        network = {
          format-wifi = "󰤨 {signalStrength}%";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}\n{essid}";
          on-click = "nm-connection-editor";
        };

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {device_alias}";
          format-disabled = "󰂲";
          on-click = "blueman-manager";
          tooltip-format = "{controller_alias}\n{num_connections} connected";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };

        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "󰗑";
            performance = "󱐋";
            balanced = "󰗑";
            power-saver = "󰌪";
          };
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
        border-bottom: 2px solid rgba(137, 180, 250, 0.3);
      }

      #workspaces button {
        padding: 0 5px;
        color: #6c7086;
        border-radius: 4px;
      }

      #workspaces button.active {
        color: #89b4fa;
      }

      #clock, #battery, #network, #bluetooth, #pulseaudio,
      #power-profiles-daemon, #tray, #idle-inhibitor {
        padding: 0 10px;
      }

      #battery.warning {
        color: #f9e2af;
      }

      #battery.critical {
        color: #f38ba8;
        animation: blink 1s linear infinite;
      }

      @keyframes blink {
        to { color: #1e1e2e; }
      }
    '';
  };

  # ── Hyprpaper (wallpaper) ───────────────────────────────────────────────────
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/the-legend-of-zelda-breath-of-the-wild-1600x900-nintendo-switch-wii-u-5803.jpg"
        "~/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/wallhaven-4lqqqq.jpg"
      ];
      wallpaper = [
        "eDP-1,~/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/the-legend-of-zelda-breath-of-the-wild-1600x900-nintendo-switch-wii-u-5803.jpg"
        ",~/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/wallhaven-4lqqqq.jpg"
      ];
    };
  };

  # ── Hypridle (idle management — aggressive for battery) ─────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 120;  # 2 min — dim screen
          on-timeout = "brightnessctl -s set 30%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 300;  # 5 min — lock
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;  # 10 min — screen off
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;  # 15 min — suspend
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # ── Hyprlock (lock screen) ──────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 5;
        hide_cursor = true;
      };

      background = [{
        path = "~/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/the-legend-of-zelda-breath-of-the-wild-1600x900-nintendo-switch-wii-u-5803.jpg";
        blur_passes = 3;
        blur_size = 8;
      }];

      input-field = [{
        size = "250, 50";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.3;
        outer_color = "rgba(137, 180, 250, 0.7)";
        inner_color = "rgba(30, 30, 46, 0.9)";
        font_color = "rgb(205, 214, 244)";
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;
        position = "0, -20";
        halign = "center";
        valign = "center";
      }];

      label = [{
        text = "$TIME";
        font_size = 64;
        color = "rgba(205, 214, 244, 0.9)";
        position = "0, 80";
        halign = "center";
        valign = "center";
      }];
    };
  };

  # ── Mako (notifications) ────────────────────────────────────────────────────
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = "#1e1e2edd";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      border-radius = 8;
      border-size = 2;
      padding = "12";
      default-timeout = 5000;
      max-visible = 3;
      layer = "overlay";
    };
  };

  # ── Packages ────────────────────────────────────────────────────────────────
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.jetbrains-mono
    # Core Hyprland utilities
    grimblast              # screenshot tool (hyprwm official)
    hyprpicker             # color picker
    wl-clipboard           # clipboard (wl-copy / wl-paste)
    cliphist               # clipboard history manager

    # App launcher
    wofi                   # application launcher

    # System tray apps
    blueman                # bluetooth manager (tray)
    pavucontrol            # PulseAudio/PipeWire volume control

    # OSD
    swayosd                # on-screen display for vol/brightness

    # File manager (shared with Plasma)
    kdePackages.dolphin
    kdePackages.qtsvg      # SVG icons in dolphin

    # Terminal
    kitty

    # Misc
    libnotify              # notify-send
    wlsunset               # night light / blue light filter
    polkit_gnome           # polkit authentication agent
  ];

  # ── Wofi config ─────────────────────────────────────────────────────────────
  xdg.configFile."wofi/style.css".text = ''
    window {
      margin: 0px;
      border: 2px solid #89b4fa;
      border-radius: 8px;
      background-color: #1e1e2e;
    }

    #input {
      margin: 5px;
      border: none;
      color: #cdd6f4;
      background-color: #313244;
      border-radius: 4px;
    }

    #inner-box {
      margin: 5px;
      border: none;
      background-color: #1e1e2e;
    }

    #outer-box {
      margin: 5px;
      border: none;
      background-color: #1e1e2e;
    }

    #entry:selected {
      background-color: #313244;
      border-radius: 4px;
    }

    #text {
      margin: 5px;
      color: #cdd6f4;
    }
  '';

  # ── Electron / Chromium Wayland hints ───────────────────────────────────────
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
