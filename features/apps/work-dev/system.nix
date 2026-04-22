{ config, pkgs, lib, ... }:

let
  cfg = config.custom.work-dev;
in
{
  options.custom.work-dev = {
    polkitOwners = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users to grant 1Password polkit access";
    };
  };

  config = {
    # 1Password requires system-level hooks for polkit/biometrics
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = cfg.polkitOwners;
    };
  };
}
