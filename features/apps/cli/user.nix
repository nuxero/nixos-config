{ config, pkgs, lib, ... }:

let
  cfg = config.custom.cli;
in
{
  options.custom.cli = {
    gitUserName = lib.mkOption {
      type = lib.types.str;
      description = "Git user.name";
    };
    gitUserEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user.email";
    };
  };

  config = {
    home.packages = with pkgs; [
      vim wget btop eza bat fastfetch
      nh nix-output-monitor nvd poppler-utils
    ];

    programs.git = {
      enable = true;
      userName = cfg.gitUserName;
      userEmail = cfg.gitUserEmail;
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

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
