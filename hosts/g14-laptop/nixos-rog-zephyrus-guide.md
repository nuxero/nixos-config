# NixOS on ASUS ROG Zephyrus (2023) — Wayland + NVIDIA Offload + Samsung 990 EVO Plus

A practical guide covering configuration, best practices, and known issues for running NixOS on a 2023 ROG Zephyrus with hybrid GPU mode (NVIDIA offload), Wayland, and a Samsung 990 EVO Plus NVMe SSD.

---

## Table of Contents

1. [Hardware Overview](#hardware-overview)
2. [NixOS Base Configuration](#nixos-base-configuration)
3. [NVIDIA Hybrid / Offload Mode](#nvidia-hybrid--offload-mode)
4. [Wayland Configuration](#wayland-configuration)
5. [Samsung 990 EVO Plus SSD](#samsung-990-evo-plus-ssd)
6. [ASUS ROG-Specific Tooling](#asus-rog-specific-tooling)
7. [Power Management](#power-management)
8. [Best Practices](#best-practices)
9. [Known Issues](#known-issues)
10. [Useful Commands](#useful-commands)

---

## Hardware Overview

| Component | Typical Spec |
|-----------|-------------|
| CPU | AMD Ryzen 9 7940HS (G14) or Intel i9-13900H (M16/G16) |
| iGPU | AMD Radeon 780M (RDNA 3) or Intel Iris Xe |
| dGPU | NVIDIA RTX 4060/4070/4090 Mobile |
| SSD | Samsung 990 EVO Plus (NVMe PCIe 5.0 x2 / PCIe 4.0 x4) |
| Display | Internal panel driven by the iGPU (MUX-less or with MUX switch depending on model) |

---

## NixOS Base Configuration

### Kernel

Use a recent stable or latest kernel. The 2023 Zephyrus benefits from kernel 6.5+ for improved AMD/NVIDIA support.

```nix
# configuration.nix
boot.kernelPackages = pkgs.linuxPackages_latest;
```

### Firmware & Microcode

```nix
hardware.enableRedistributableFirmware = true;
hardware.cpu.amd.updateMicrocode = true;
```

### Filesystem (if using Btrfs on the 990 EVO Plus)

```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/<your-uuid>";
  fsType = "btrfs";
  options = [ "compress=zstd" "noatime" "ssd" "discard=async" "space_cache=v2" ];
};
```

---

## NVIDIA Hybrid / Offload Mode

This is the core of the setup. The AMD iGPU drives the display and desktop; the NVIDIA dGPU is powered on only when explicitly requested via `nvidia-offload`.

### Driver Configuration

```nix
# Enable OpenGL / graphics (renamed from hardware.opengl in NixOS 24.11)
hardware.graphics.enable = true;

# NVIDIA driver
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
  modesetting.enable = true;

  # Use the open-source kernel module (supported on RTX 40-series)
  open = true;

  # Power management — lets the dGPU suspend when idle
  powerManagement.enable = true;
  powerManagement.finegrained = true;

  # Use the production driver branch
  package = config.boot.kernelPackages.nvidiaPackages.production;

  # PRIME offload configuration
  prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;  # provides the `nvidia-offload` wrapper
    };

    # Bus IDs — verify with `lspci | grep -E 'VGA|3D'`
    amdgpuBusId = "PCI:6:0:0";   # adjust to your system
    nvidiaBusId = "PCI:1:0:0";   # adjust to your system
  };
};
```

### Finding Your Bus IDs

```bash
lspci | grep -E 'VGA|3D'
# Example output:
# 01:00.0 3D controller: NVIDIA Corporation AD107M ...
# 06:00.0 VGA compatible controller: AMD/ATI ...
#
# Convert to NixOS format: 01:00.0 -> "PCI:1:0:0", 06:00.0 -> "PCI:6:0:0"
```

### Running Apps on the dGPU

```bash
nvidia-offload glxinfo | grep "OpenGL renderer"
nvidia-offload steam
nvidia-offload mangohud gamescope -- <game>
```

---

## Wayland Configuration

### GNOME (Wayland)

```nix
services.xserver.enable = true;
services.xserver.displayManager.gdm.enable = true;
services.xserver.displayManager.gdm.wayland = true;
services.xserver.desktopManager.gnome.enable = true;
```

### Hyprland (Wayland compositor)

```nix
programs.hyprland = {
  enable = true;
  xwayland.enable = true;
};
```

### Sway

```nix
programs.sway = {
  enable = true;
  wrapperFeatures.gtk = true;
};
```

### Critical Environment Variables for NVIDIA + Wayland

These are essential for a stable experience. Set them globally or in your compositor config:

```nix
environment.sessionVariables = {
  # Tell Wayland apps to run natively
  NIXOS_OZONE_WL = "1";

  # Prevent EGLStream issues — use GBM backend
  GBM_BACKEND = "nvidia-drm";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";

  # Needed for some Electron / Chromium apps under Wayland
  ELECTRON_OZONE_PLATFORM_HINT = "auto";

  # Firefox Wayland
  MOZ_ENABLE_WAYLAND = "1";

  # Cursor fix for NVIDIA Wayland
  WLR_NO_HARDWARE_CURSORS = "1";
};
```

> **Note:** Setting `GBM_BACKEND` and `__GLX_VENDOR_LIBRARY_NAME` globally can break apps running on the iGPU. If you experience issues, set these only when launching offloaded apps (the `nvidia-offload` wrapper handles this). Remove them from `sessionVariables` if your desktop runs on the iGPU.

---

## Samsung 990 EVO Plus SSD

### NVMe Kernel Support

The 990 EVO Plus works out of the box on kernel 6.5+. Ensure the NVMe module loads early:

```nix
boot.initrd.availableKernelModules = [
  "nvme" "xhci_pci" "thunderbolt" "ahci" "usbhid" "usb_storage" "sd_mod"
];
```

### TRIM / Discard

Enable periodic TRIM for SSD longevity:

```nix
services.fstrim = {
  enable = true;
  interval = "weekly";
};
```

If using `discard=async` in your mount options (recommended for Btrfs), continuous TRIM is already handled. `fstrim` serves as a safety net.

### Filesystem Recommendations

| Filesystem | Mount Options |
|-----------|--------------|
| Btrfs | `compress=zstd,noatime,ssd,discard=async,space_cache=v2` |
| ext4 | `noatime,discard` |
| XFS | `noatime,discard` |

### Thermal Throttling Awareness

The 990 EVO Plus can throttle under sustained writes in the enclosed Zephyrus chassis. There is no user-serviceable heatsink on most M.2 slots in this laptop. Monitor with:

```bash
sudo nvme smart-log /dev/nvme0
# Look at "temperature" and "warning_temp_time"
```

Install `nvme-cli`:

```nix
environment.systemPackages = [ pkgs.nvme-cli ];
```

---

## ASUS ROG-Specific Tooling

### asusctl & supergfxctl

The `asus-linux` project provides essential ROG hardware control. NixOS has upstream support:

```nix
services.asusd = {
  enable = true;
  enableUserService = true;
};

# supergfxd manages GPU switching (hybrid/integrated/dedicated)
services.supergfxd.enable = true;
```

This gives you:

- `asusctl` — control keyboard LEDs, fan profiles, charge limit, screen refresh rate
- `supergfxctl` — switch GPU modes without rebooting (hybrid / integrated / dedicated)

### Fan Profiles

```bash
asusctl profile -l          # list profiles
asusctl profile -P quiet    # set quiet mode
asusctl profile -P balanced
asusctl profile -P performance
```

### Battery Charge Limit

Preserve battery health by capping charge:

```bash
asusctl -c 80   # limit charge to 80%
```

---

## Power Management

### TLP (optional, conflicts with power-profiles-daemon)

```nix
services.tlp = {
  enable = true;
  settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    RUNTIME_PM_ON_BAT = "auto";
  };
};

# Disable power-profiles-daemon if using TLP
services.power-profiles-daemon.enable = false;
```

### NVIDIA dGPU Suspend

With `powerManagement.finegrained = true`, the dGPU should power down when idle. Verify:

```bash
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
# Should show "suspended" when idle
```

---

## Best Practices

### General

1. **Pin your NixOS channel or use flakes** — reproducibility prevents surprise regressions after updates.
2. **Keep a known-good generation** — always have a rollback option in the bootloader. Never garbage-collect your last working generation before testing a new one.
3. **Use `hardware.nix` from nixos-hardware** — the community maintains ROG Zephyrus-specific profiles:
   ```nix
   # flake.nix
   inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";

   # In your module imports (for the 2023 G14 with NVIDIA):
   imports = [
     nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia
     # Other available variants:
     #   asus-zephyrus-ga402x-amdgpu  (AMD-only GPU mode)
     #   asus-zephyrus-ga402           (2022 G14)
     # Check the repo for your exact model
   ];
   ```

### NVIDIA + Wayland

4. **Prefer the open kernel module** (`hardware.nvidia.open = true`) on RTX 40-series — it is better maintained for Wayland and required for fine-grained power management.
5. **Don't set `GBM_BACKEND` / `__GLX_VENDOR_LIBRARY_NAME` globally** unless your display is wired directly to the NVIDIA GPU. On hybrid setups the iGPU drives the display; setting these globally causes black screens or glitches.
6. **Use `WLR_NO_HARDWARE_CURSORS = "1"`** if you see invisible or corrupted cursors on wlroots-based compositors (Sway, Hyprland).
7. **Test with `nvidia-offload`** before assuming the dGPU is broken — many apps default to the iGPU, which is correct behavior in offload mode.

### SSD

8. **Enable `discard=async`** (Btrfs) or periodic `fstrim` — the 990 EVO Plus benefits from TRIM for sustained write performance.
9. **Avoid `discard` (synchronous) on Btrfs** — use `discard=async` instead; synchronous discard causes write latency spikes.
10. **Monitor SSD temperature** during heavy workloads (large compilations, game installs). Throttling is silent and can look like a system hang.

### Security

11. **Enable Secure Boot** if possible — NixOS supports it via `lanzaboote`:
    ```nix
    boot.loader.systemd-boot.enable = false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    ```
12. **Use LUKS encryption** — the 990 EVO Plus has hardware encryption support, but software LUKS is more trustworthy and well-tested on Linux.

---

## Known Issues

### NVIDIA + Wayland

| Issue | Description | Workaround |
|-------|-------------|------------|
| **Black screen after login** | `GBM_BACKEND=nvidia-drm` set globally on a hybrid setup | Remove from global session variables; only use with `nvidia-offload` |
| **Flickering / artifacts** | NVIDIA driver regression on certain kernel + driver combos | Pin a known-good driver version; check NVIDIA 545+ release notes |
| **Cursor invisible** | wlroots compositors don't render hardware cursor with NVIDIA | Set `WLR_NO_HARDWARE_CURSORS=1` |
| **Suspend/resume crash** | dGPU fails to resume from D3 sleep | Ensure `hardware.nvidia.powerManagement.enable = true`; update to driver 545+ |
| **Screen tearing on iGPU** | AMD iGPU compositing issue | Enable `services.xserver.videoDrivers = [ "nvidia" ]` (not `"modesetting"`) and ensure `hardware.graphics.enable = true` |
| **XWayland apps blurry** | Fractional scaling not applied to XWayland | Use integer scaling, or enable experimental fractional scaling in your compositor |
| **Electron apps crash** | Missing Ozone flags | Set `ELECTRON_OZONE_PLATFORM_HINT=auto` or launch with `--ozone-platform=wayland` |

### Samsung 990 EVO Plus

| Issue | Description | Workaround |
|-------|-------------|------------|
| **Thermal throttling** | Sustained writes cause temp > 70°C in enclosed chassis | Reduce write-heavy parallel jobs; consider a thermal pad mod |
| **PCIe link speed** | May negotiate PCIe 4.0 x4 instead of 5.0 x2 depending on slot | Check with `sudo lspci -vv \| grep -A5 "NVMe"` — most Zephyrus M.2 slots are Gen4 |
| **APST power state issues** | Aggressive NVMe power saving causes intermittent freezes on some firmware versions | Add `nvme_core.default_ps_max_latency_us=5500` to kernel params, or update SSD firmware via Samsung Magician (Windows) |
| **Firmware updates** | Samsung Magician is Windows-only | Use a Windows USB boot drive or `fwupd` if Samsung publishes LVFS updates (check `fwupdmgr get-devices`) |

### ROG Hardware

| Issue | Description | Workaround |
|-------|-------------|------------|
| **Keyboard backlight not saved** | aura settings reset on reboot | Use `asusctl` to set LED mode; ensure `asusd` service is enabled |
| **supergfxctl mode switch fails** | Switching from hybrid to integrated while apps use dGPU | Close all GPU-bound apps first; check `supergfxctl -g` for current state |
| **Fn key media controls** | Some Fn combos not recognized | Ensure `asus-nb-wmi` kernel module is loaded; check `dmesg` for WMI errors |
| **High idle power draw** | dGPU not entering D3 suspend | Verify fine-grained power management is active; check `runtime_status` sysfs node |

---

## Useful Commands

```bash
# Check GPU status
supergfxctl -g                              # current GPU mode
nvidia-smi                                  # dGPU status (only works if dGPU is awake)
cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status

# Test offload
nvidia-offload glxinfo | grep "OpenGL renderer"
nvidia-offload vulkaninfo --summary

# SSD health
sudo nvme smart-log /dev/nvme0
sudo smartctl -a /dev/nvme0n1

# System logs for debugging
journalctl -b -p err                        # errors since last boot
journalctl -b -u asusd                      # asusd logs
journalctl -b --grep="nvidia"               # nvidia-related messages
dmesg | grep -i "nvme\|samsung"             # SSD kernel messages

# NixOS rebuild
sudo nixos-rebuild switch --flake .#myhost  # if using flakes
sudo nixos-rebuild switch                   # if using channels
sudo nixos-rebuild boot                     # build but apply on next boot (safer)
```

---

## Minimal Complete Example

A condensed `configuration.nix` snippet tying everything together:

```nix
{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" ];
  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=5500" ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  services.asusd = { enable = true; enableUserService = true; };
  services.supergfxd.enable = true;
  services.fstrim.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  environment.systemPackages = with pkgs; [
    nvme-cli
    smartmontools
    pciutils
    glxinfo
    vulkan-tools
  ];
}
```

> **Remember:** Adjust `amdgpuBusId` and `nvidiaBusId` to match your actual hardware. Run `lspci | grep -E 'VGA|3D'` and convert the addresses.

---

*Last updated: April 2026. Verify driver versions and NixOS options against the current NixOS manual and NVIDIA release notes.*
