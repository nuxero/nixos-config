{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    reaper
    vital
    decent-sampler
  ];
}
