{ config, pkgs, ... }:

{
  # 1Password requires system-level hooks for polkit/biometrics
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "hector" ];
  };

  home-manager.users.hector = {
    home.packages = with pkgs; [
      # Work & Cloud
      maestral
      maestral-gui
      firefox
      slack
      google-chrome
      dbeaver-bin
      awscli2
      git
      
      # Dev Tools & Modern CLI
      kiro
      kiro-cli
      vim wget btop eza bat

      # Multimedia
      exaile
      vlc
      
      # NH Tooling
      nh nix-output-monitor nvd nix-index
    ];

    # --- CLI & Dotfiles Management ---
    
    programs.git = {
      enable = true;
      userName = "Hector Zelaya";
      userEmail = "inge.zelaya@gmail.com";
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "vim";
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ll = "eza -l";
        la = "eza -la";
        update = "nh os switch --update";
        ".." = "cd ..";
      };
      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"
        
        # Helper function: make a directory and instantly cd into it
        mkcd() {
          mkdir -p "$1" && cd "$1"
        }
      '';
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[✗](bold red)";
        };
        package.disabled = true; 
      };
    };

    # Direnv for per-project flakes
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Autostart Maestral (GUI and Tray Icon)
    systemd.user.services.maestral-gui = {
      Unit = { Description = "Maestral Dropbox GUI"; };
      Service = { 
        ExecStart = "${pkgs.maestral-gui}/bin/maestral-gui"; 
        Restart = "on-failure"; 
      };
      Install = { 
        # Starts when your desktop environment loads, rather than just on boot
        WantedBy = [ "graphical-session.target" ]; 
      };
    };
  };
}