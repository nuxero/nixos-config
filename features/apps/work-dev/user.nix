{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Work & Cloud
    maestral
    maestral-gui
    slack
    google-chrome
    dbeaver-bin
    awscli2
    git

    # Dev Tools & Modern CLI
    kiro
    kiro-cli
    vim wget btop eza bat fastfetch

    # Multimedia
    exaile
    vlc

    # NH Tooling
    nh nix-output-monitor nvd
  ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
  };

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

  # Autostart Maestral via XDG (Plasma picks this up natively)
  xdg.configFile."autostart/maestral-gui.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Maestral
    Exec=${pkgs.bash}/bin/bash -c "sleep 5 && ${pkgs.maestral-gui}/bin/maestral_qt"
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';
}
