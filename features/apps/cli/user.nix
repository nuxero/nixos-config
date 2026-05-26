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
    gitSmtpServer = lib.mkOption {
      type = lib.types.str;
      default = "smtp.gmail.com";
      description = "SMTP server for git send-email";
    };
    gitSmtpServerPort = lib.mkOption {
      type = lib.types.int;
      default = 587;
      description = "SMTP server port for git send-email";
    };
    gitSmtpEncryption = lib.mkOption {
      type = lib.types.str;
      default = "tls";
      description = "SMTP encryption method for git send-email (tls or ssl)";
    };
    gitSmtpUser = lib.mkOption {
      type = lib.types.str;
      default = cfg.gitUserEmail;
      description = "SMTP user for git send-email (defaults to gitUserEmail)";
    };
  };

  config = {
    home.packages = with pkgs; [
      vim wget btop eza bat fastfetch
      nh nix-output-monitor nvd poppler-utils
    ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        user.name = cfg.gitUserName;
        user.email = cfg.gitUserEmail;
        alias = {
          ci = "commit";
          co = "checkout";
          s = "status";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "vim";
        sendemail = {
          smtpServer = cfg.gitSmtpServer;
          smtpServerPort = cfg.gitSmtpServerPort;
          smtpEncryption = cfg.gitSmtpEncryption;
          smtpUser = cfg.gitSmtpUser;
          confirm = "auto";
        };
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
