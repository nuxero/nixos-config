{ config, pkgs, ... }:

{
  # Override aggressive power settings from nixos-hardware that cause GPU crashes
  boot.kernelParams = [
    "pcie_aspm.policy=default"        # override powersupersave — NVIDIA GPUs crash with aggressive ASPM
    "mem_sleep_default=s2idle"         # override deep — avoids amdgpu DMCUB errors on suspend
    "amdgpu.dcdebugmask=0x10"         # disable PSR — fixes DMCUB diagnostic data errors
  ];

  services.asusd.enable = true;
  services.supergfxd.enable = true;
  programs.rog-control-center.enable = true;
  services.power-profiles-daemon.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # supergfxd handles RTD3 PM; having both causes GSP firmware crash
    open = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:65:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
