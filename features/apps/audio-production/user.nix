{ config, pkgs, lib, ... }:

let
  # Reaper 7.66+ supports ffmpeg 5+ and its hardware encoding/decoding.
  # The nixpkgs reaper package still bundles ffmpeg_4-headless in LD_LIBRARY_PATH,
  # whose nv-codec-headers are too old for modern NVIDIA drivers (RTX 40-series).
  # The error "Cannot get the preset configuration: unsupported param" is caused by
  # the NVENC API version mismatch between ffmpeg 4's nv-codec-headers and the driver.
  # Swap to ffmpeg_7-headless which ships nv-codec-headers-12 (NVENC already enabled
  # by default in the headless variant on x86_64-linux).
  # See: https://reaper.blog/2026/03/766-update/
  #      https://github.com/HaveAGitGat/Tdarr/issues/797
  reaper-nvenc = pkgs.reaper.overrideAttrs (oldAttrs: {
    # makeLibraryPath uses lib.getLib, which resolves to the "lib" output.
    # We must replace that specific output path, not the default (bin) output.
    installPhase = builtins.replaceStrings
      [ "${lib.getLib pkgs.ffmpeg_4-headless}" ]
      [ "${lib.getLib pkgs.ffmpeg_7-headless}" ]
      oldAttrs.installPhase;
  });
in
{
  home.packages = with pkgs; [
    reaper-nvenc
    vital
    decent-sampler
  ];
}
