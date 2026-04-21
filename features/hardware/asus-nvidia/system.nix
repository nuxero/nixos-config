{ config, pkgs, ... }:

{
  # Override nixos-hardware ga402x/shared.nix aggressive power settings that cause GPU crashes.
  # shared.nix unconditionally sets mem_sleep_default=deep and pcie_aspm.policy=powersupersave;
  # for duplicate kernel params the last value wins, so appending our values is correct.
  boot.kernelParams = [
    "pcie_aspm.policy=performance"        # TEMPORARY: disable all PCIe ASPM power saving — testing if Samsung 990 EVO Plus
                                          # PCIe link negotiation causes silent freezes. Overrides policy=default below.
                                          # Remove and revert to policy=default once SSD is confirmed/ruled out as cause.
    "pcie_aspm.policy=default"            # override powersupersave — NVIDIA GPUs crash with aggressive ASPM
                                          # (currently overridden by policy=performance above)
    "mem_sleep_default=s2idle"            # override deep — avoids amdgpu DMCUB errors on suspend
    "amdgpu.dcdebugmask=0x10"            # disable PSR — fixes DMCUB diagnostic data errors
                                          # REVISIT: increases power draw; PSR bug may be fixed in kernel 6.13.8+, re-test periodically
    "amdgpu.gpu_recovery=1"              # force GPU reset on ring timeout instead of escalating to sync flood
    "amdgpu.ppfeaturemask=0xfffd3fff"    # disable GFXOFF (bit 13) — prevents gfx ring hangs on Rembrandt iGPU
                                          # REVISIT: increases power draw; re-test on future kernels
    "nvidia.NVreg_EnableGpuFirmware=0"   # disable GSP firmware — GSP never initializes, causing heartbeat timeouts
                                          # WARNING: only works with proprietary module (open=false); NVIDIA is deprecating
                                          # proprietary modules post-580 — this workaround has a limited lifespan
    "nvidia_modeset.vblank_sem_control=0" # fix KWin Wayland black screen + cursor-only after suspend resume
    "nvme_core.default_ps_max_latency_us=0" # disable NVMe APST — prevents Samsung 990 EVO Plus controller resets
                                          # REVISIT: =0 fully disables NVMe power saving; try =5500 once stable, or check for SSD firmware update
  ];

  hardware.nvidia.dynamicBoost.enable = true;  # enables nvidia-powerd — supergfxd expects this service

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
                   # WARNING: NVIDIA dropping proprietary modules post-580; will need to revisit when GSP is fixed upstream
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:65:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
