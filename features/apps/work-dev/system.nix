{ polkitOwners }:

{ config, pkgs, ... }:

{
  # 1Password requires system-level hooks for polkit/biometrics
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = polkitOwners;
  };
}
