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
      # External display to the LEFT of the built-in panel
      # Format: name, resolution, position, scale
      monitor = [
        "eDP-1,preferred,auto,1.45"        # internal: 1.25x scale
        "DP-2,preferred,auto-left,1"       # external: left of internal
        ",preferred,auto,1"                # fallback for any other monitor
      ];

      # ── Input ───────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us,latam";
        kb_options = "grp:alt_shift_toggle";  # Alt+Shift to switch layout
        follow_mouse = 1;
        natural_scroll = true;  # natural scroll for mouse
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
      # NOTE: waybar is started via systemd (programs.waybar.systemd.enable)
      exec-once = [
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
        "$mod, Space, exec, wofi --show drun --allow-images"
        "$mod, E, exec, thunar"

        # ── Alt+Tab: window switcher across all workspaces ──────────────────
        "ALT, Tab, exec, rofi -show window -show-icons"
        "ALT SHIFT, Tab, exec, rofi -show window -show-icons"

        # ── Pinned app launchers (Meta+1–9): launch or focus ────────────────
        # These match the visual order in the wlr/taskbar
        "$mod, 1, exec, ~/.config/hypr/scripts/launch-or-focus.sh slack"
        "$mod, 2, exec, ~/.config/hypr/scripts/launch-or-focus.sh google-chrome-stable"
        "$mod, 3, exec, ~/.config/hypr/scripts/launch-or-focus.sh firefox"
        "$mod, 4, exec, ~/.config/hypr/scripts/launch-or-focus.sh kiro"
        "$mod, 5, exec, ~/.config/hypr/scripts/launch-or-focus.sh kitty"
        "$mod, 6, exec, ~/.config/hypr/scripts/launch-or-focus.sh thunar"
        "$mod, 7, exec, ~/.config/hypr/scripts/launch-or-focus.sh 1password"
        "$mod, 8, exec, ~/.config/hypr/scripts/launch-or-focus.sh cockos-reaper"
        "$mod, 9, exec, ~/.config/hypr/scripts/launch-or-focus.sh exaile"

        # ── Power menu ──────────────────────────────────────────────────────
        "$mod SHIFT, Escape, exec, ~/.config/hypr/scripts/power-menu.sh"

        # ── Window management ───────────────────────────────────────────────
        "$mod, Q, killactive"
        "ALT, F4, killactive"
        "$mod, F, fullscreen, 0"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, S, togglesplit"
        "$mod, Prior, fullscreen, 1"       # Meta+PgUp: maximize
        "$mod, Next, togglespecialworkspace, minimize"  # Meta+PgDown: minimize (scratchpad)
        "$mod, D, exec, hyprctl dispatch togglespecialworkspace overview"  # Meta+D: show desktop

        # ── Keyboard layout toggle ──────────────────────────────────────────
        "$mod ALT, K, exec, hyprctl switchxkblayout all next"

        # ── Lock screen ─────────────────────────────────────────────────────
        "$mod, Escape, exec, hyprlock"
        "CTRL ALT, L, exec, hyprlock"

        # ── Focus (vim-style, matching Krohnkite) ───────────────────────────
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # ── Window snapping (Meta+arrows, matching KDE) ─────────────────────
        "$mod, Left, movewindow, l"
        "$mod, Right, movewindow, r"
        "$mod, Up, movewindow, u"
        "$mod, Down, movewindow, d"

        # ── Move windows (Shift+vim keys, matching Krohnkite) ──────────────
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # ── Workspaces (Meta + F1–F12) ──────────────────────────────────────
        "$mod, F1, workspace, 1"
        "$mod, F2, workspace, 2"
        "$mod, F3, workspace, 3"
        "$mod, F4, workspace, 4"
        "$mod, F5, workspace, 5"
        "$mod, F6, workspace, 6"
        "$mod, F7, workspace, 7"
        "$mod, F8, workspace, 8"
        "$mod, F9, workspace, 9"
        "$mod, F10, workspace, 10"
        "$mod, F11, workspace, 11"
        "$mod, F12, workspace, 12"

        # ── Move to workspace (Meta + Shift + F1–F12) ───────────────────────
        "$mod SHIFT, F1, movetoworkspace, 1"
        "$mod SHIFT, F2, movetoworkspace, 2"
        "$mod SHIFT, F3, movetoworkspace, 3"
        "$mod SHIFT, F4, movetoworkspace, 4"
        "$mod SHIFT, F5, movetoworkspace, 5"
        "$mod SHIFT, F6, movetoworkspace, 6"
        "$mod SHIFT, F7, movetoworkspace, 7"
        "$mod SHIFT, F8, movetoworkspace, 8"
        "$mod SHIFT, F9, movetoworkspace, 9"
        "$mod SHIFT, F10, movetoworkspace, 10"
        "$mod SHIFT, F11, movetoworkspace, 11"
        "$mod SHIFT, F12, movetoworkspace, 12"

        # ── Special workspace (scratchpad) ──────────────────────────────────
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"

        # ── Screenshots (grimblast) ─────────────────────────────────────────
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy output"
        "$mod, Print, exec, grimblast copy window"

        # ── Clipboard history ───────────────────────────────────────────────
        "$mod SHIFT, V, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

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

      # ── Workspace-to-monitor binding ─────────────────────────────────────────
      # 1–5 → external (DP-2, left), 6–10 → internal (eDP-1, right)
      # When DP-2 is disconnected, Hyprland moves all workspaces to eDP-1 automatically.
      workspace = [
        "1, monitor:DP-2, default:true"
        "2, monitor:DP-2"
        "3, monitor:DP-2"
        "4, monitor:DP-2"
        "5, monitor:DP-2"
        "6, monitor:eDP-1, default:true"
        "7, monitor:eDP-1"
        "8, monitor:eDP-1"
        "9, monitor:eDP-1"
        "10, monitor:eDP-1"
        "11, monitor:eDP-1"
        "12, monitor:eDP-1"
      ];

      # ── Window rules ────────────────────────────────────────────────────────
      windowrule = [
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(.blueman-manager-wrapped)$"
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "float, class:^(thunar)$, title:^(File Operation Progress)$"
      ];
    };
  };

  # ── Waybar ──────────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.targets = [ "hyprland-session.target" ];

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
          "custom/sep"
          "custom/app1"
          "custom/app2"
          "custom/app3"
          "custom/app4"
          "custom/app5"
          "custom/app6"
          "custom/app7"
          "custom/app8"
          "custom/app9"
          "custom/sep2"
          "wlr/taskbar"
        ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "hyprland/language"
          "pulseaudio"
          "network"
          "bluetooth"
          "power-profiles-daemon"
          "battery"
          "clock"
        ];

        # ── Pinned app launchers (Meta+1–9) ─────────────────────────────────
        "custom/sep" = { format = "│"; tooltip = false; };
        "custom/sep2" = { format = "│"; tooltip = false; };

        "custom/app1" = {
          format = "󰍡";
          tooltip-format = "1: Slack";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh slack";
        };
        "custom/app2" = {
          format = "";
          tooltip-format = "2: Chrome";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh google-chrome-stable";
        };
        "custom/app3" = {
          format = "";
          tooltip-format = "3: Firefox";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh firefox";
        };
        "custom/app4" = {
          format = "󰘐";
          tooltip-format = "4: Kiro";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh kiro";
        };
        "custom/app5" = {
          format = "";
          tooltip-format = "5: Terminal";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh kitty";
        };
        "custom/app6" = {
          format = "󰉋";
          tooltip-format = "6: Files";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh thunar";
        };
        "custom/app7" = {
          format = "󰌋";
          tooltip-format = "7: 1Password";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh 1password";
        };
        "custom/app8" = {
          format = "󰎆";
          tooltip-format = "8: Reaper";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh cockos-reaper";
        };
        "custom/app9" = {
          format = "󰝚";
          tooltip-format = "9: Exaile";
          on-click = "~/.config/hypr/scripts/launch-or-focus.sh exaile";
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          all-outputs = true;
          format-icons = {
            active = "●";
            default = "○";
          };
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 18;
          tooltip-format = "{title}";
          on-click = "activate";
          on-click-middle = "close";
          all-outputs = true;
        };

        "hyprland/language" = {
          format = "󰌌 {}";
          format-en = "EN";
          format-es = "LATAM";
          on-click = "hyprctl switchxkblayout all next";
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

      #custom-sep, #custom-sep2 {
        color: #45475a;
        padding: 0 4px;
      }

      #custom-app1, #custom-app2, #custom-app3, #custom-app4,
      #custom-app5, #custom-app6, #custom-app7, #custom-app8, #custom-app9 {
        padding: 0 6px;
        color: #bac2de;
      }

      #custom-app1:hover, #custom-app2:hover, #custom-app3:hover, #custom-app4:hover,
      #custom-app5:hover, #custom-app6:hover, #custom-app7:hover, #custom-app8:hover,
      #custom-app9:hover {
        color: #89b4fa;
      }

      #clock, #battery, #network, #bluetooth, #pulseaudio,
      #power-profiles-daemon, #tray, #idle-inhibitor, #language {
        padding: 0 10px;
      }

      #taskbar button {
        padding: 0 4px;
      }

      #taskbar button.active {
        background-color: rgba(137, 180, 250, 0.2);
        border-radius: 4px;
      }

      #language {
        color: #a6e3a1;
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
  # Symlink wallpapers to a path without spaces (avoids potential parsing issues)
  home.file.".config/hypr/wallpapers/zelda.jpg".source =
    config.lib.file.mkOutOfStoreSymlink
      "/home/hector/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/the-legend-of-zelda-breath-of-the-wild-1600x900-nintendo-switch-wii-u-5803.jpg";
  home.file.".config/hypr/wallpapers/wallhaven.jpg".source =
    config.lib.file.mkOutOfStoreSymlink
      "/home/hector/Dropbox (Maestral)/HECTOR DANIEL/wallpapers/wallhaven-4lqqqq.jpg";

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/home/hector/.config/hypr/wallpapers/zelda.jpg"
        "/home/hector/.config/hypr/wallpapers/wallhaven.jpg"
      ];
      wallpaper = [
        {
          monitor = "eDP-1";
          path = "/home/hector/.config/hypr/wallpapers/zelda.jpg";
        }
        {
          monitor = "";
          path = "/home/hector/.config/hypr/wallpapers/wallhaven.jpg";
        }
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
        path = "/home/hector/.config/hypr/wallpapers/zelda.jpg";
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
      layer = "top";
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
    rofi                   # window switcher + power menu

    # System tray apps
    blueman                # bluetooth manager (tray)
    pavucontrol            # PulseAudio/PipeWire volume control

    # OSD
    swayosd                # on-screen display for vol/brightness

    # File manager (lightweight — no KDE deps)
    thunar
    thunar-volman          # removable media management

    # Terminal
    kitty

    # Misc
    libnotify              # notify-send
    wlsunset               # night light / blue light filter
    polkit_gnome           # polkit authentication agent
    jq                     # JSON parsing (used by launch-or-focus script)
  ];

  # ── Wofi config ─────────────────────────────────────────────────────────────
  xdg.configFile."hypr/scripts/launch-or-focus.sh" = {
    source = ./scripts/launch-or-focus.sh;
    executable = true;
  };
  xdg.configFile."hypr/scripts/power-menu.sh" = {
    source = ./scripts/power-menu.sh;
    executable = true;
  };

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
