{ config, pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
    services.asusd.enable = true;
    services.supergfxd.enable = true;
    programs.rog-control-center.enable = true;
    services.power-profiles-daemon.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;
        open = true;
        prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            amdgpuBusId = "PCI:65:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
    };

    home-manager.users.hector.home.packages = [
        nvidia-offload
        pkgs.nvtopPackages.full
        pkgs.asusctl
    ];
}