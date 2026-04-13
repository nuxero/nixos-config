{ config, pkgs, ... }:

{
  # nvidia-offload is provided by hardware.nvidia.prime.offload.enableOffloadCmd in system.nix
  home.packages = [
    pkgs.nvtopPackages.full
    pkgs.asusctl
  ];
}
