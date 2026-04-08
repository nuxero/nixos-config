{ config, pkgs, ... }:

{
  # Override aggressive power settings from nixos-hardware that cause GPU crashes
  boot.kernelParams = [
    "pcie_aspm.policy=default"        # override powersupersave — NVIDIA GPUs crash with aggressive ASPM
    "mem_sleep_default=s2idle"         # override deep — avoids amdgpu DMCUB errors on suspend
    "amdgpu.dcdebugmask=0x10"         # disable PSR — fixes DMCUB diagnostic data errors
    "nvidia.NVreg_EnableGpuFirmware=0" # disable GSP firmware — GSP never initializes, causing heartbeat timeouts → sync floods
    "nvidia_modeset.vblank_sem_control=0" # fix KWin Wayland black screen + cursor-only after suspend resume
    "pcie_ports=native"                   # DIAGNOSTIC: force kernel AER driver to log PCIe errors — remove once sync flood source is identified
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
    open = false;  # proprietary modules — open modules have broken GSP on this GPU (RTX 4060 Laptop)
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:65:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
