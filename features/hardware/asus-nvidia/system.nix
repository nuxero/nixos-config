{ config, pkgs, ... }:

{
  # Override nixos-hardware ga402x/shared.nix aggressive power settings that cause GPU crashes.
  # shared.nix unconditionally sets mem_sleep_default=deep and pcie_aspm.policy=powersupersave;
  # for duplicate kernel params the last value wins, so appending our values is correct.
  boot.kernelParams = [
    "pcie_aspm.policy=default"            # override powersupersave — NVIDIA GPUs crash with aggressive ASPM
    "mem_sleep_default=s2idle"            # override deep — avoids amdgpu DMCUB errors on suspend
    "amdgpu.dcdebugmask=0x10"            # disable PSR — fixes DMCUB diagnostic data errors
    "amdgpu.gpu_recovery=1"              # force GPU reset on ring timeout instead of escalating to sync flood
    "amdgpu.ppfeaturemask=0xfffd3fff"    # disable GFXOFF (bit 13) — prevents gfx ring hangs on Rembrandt iGPU
    "nvidia.NVreg_EnableGpuFirmware=0"   # disable GSP firmware — GSP never initializes, causing heartbeat timeouts
    "nvidia_modeset.vblank_sem_control=0" # fix KWin Wayland black screen + cursor-only after suspend resume
    "nvme_core.default_ps_max_latency_us=0" # disable NVMe APST — prevents Samsung 990 EVO Plus controller resets
    "pcie_ports=native"                   # DIAGNOSTIC: keep AER logging until sync flood source is confirmed — remove once stable
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
