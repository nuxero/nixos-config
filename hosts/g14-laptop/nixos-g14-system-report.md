# NixOS System Stability Report — ASUS ROG Zephyrus G14 (GA402)

**Machine:** g14-laptop (ASUS ROG Zephyrus G14 GA402)
**Period analyzed:** March 31 – April 12, 2026
**Report generated:** April 12, 2026

---

## System Configuration

| Component | Detail |
|-----------|--------|
| CPU | AMD (Ryzen, Zen4 Phoenix) |
| iGPU | AMD Radeon (amdgpu, PCI 65:00.0) |
| dGPU | NVIDIA AD107 / RTX 4060 Max-Q (PCI 01:00.0, ID 10DE:28E0) |
| SSD | Samsung SSD 990 EVO Plus 1TB (NVMe, PCI 04:00.0) |
| WiFi | Intel iwlwifi (PCI 02:00.0), firmware 89.123cf747.0 |
| Encryption | LUKS on swap partition |
| Desktop | KDE Plasma (KWin Wayland) |
| GPU mode | Hybrid (supergfxd), NVIDIA offload via supergfxctl |

### Kernel & NixOS Versions (observed across the period)

| Period | Kernel | NixOS Generation |
|--------|--------|-----------------|
| Mar 31 (boot -46) | 6.19.10 (nouveau, no proprietary NVIDIA) | 26.05.20260328 |
| Mar 31 (boot -45 onward) | 6.19.10 (NVIDIA 595.58.03 open) | 26.05.20260328 |
| Apr 10–12 (boot -3 onward) | 6.18.21 (NVIDIA, new kernel params) | 26.05.20260409 |

### Kernel Command Line Evolution

The kernel parameters changed significantly between the two NixOS generations:

**Early (Mar 31 – Apr 9):**
```
amd_pstate=active mem_sleep_default=deep pcie_aspm.policy=powersupersave
nvidia-drm.modeset=1 nvidia-drm.fbdev=1
nvidia.NVreg_UseKernelSuspendNotifiers=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1
```

**Late (Apr 10–12):**
```
amd_pstate=active mem_sleep_default=s2idle pcie_aspm.policy=default
amdgpu.dcdebugmask=0x10 amdgpu.gpu_recovery=1 amdgpu.ppfeaturemask=0xfffd3fff
nvidia.NVreg_EnableGpuFirmware=0 nvidia_modeset.vblank_sem_control=0
nvme_core.default_ps_max_latency_us=0
nvidia-drm.modeset=1 nvidia-drm.fbdev=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1
```

Notable changes: switched from `deep` to `s2idle` sleep, relaxed PCIe ASPM from `powersupersave` to `default`, added amdgpu recovery/debug flags, disabled NVMe APST entirely (`=0`), disabled NVIDIA GPU firmware.

---

## Boot Timeline & Reboot Frequency

**47 boots in 13 days** — an average of 3.6 boots/day, indicating severe instability.

### Boot-by-Boot Timeline

| # | Boot Start | Boot End | Duration | Likely Cause of Termination |
|---|-----------|----------|----------|----------------------------|
| -46 | Mar 31 16:00 | Mar 31 16:19 | 19 min | nouveau GSP errors → reboot to switch to NVIDIA proprietary |
| -45 | Mar 31 17:24 | Mar 31 17:39 | 15 min | kwin_wayland output config failed → reboot |
| -44 | Mar 31 17:52 | Mar 31 19:55 | 2h 3m | Clean shutdown (maestral-gui broken nix store path) |
| -43 | Mar 31 20:02 | Mar 31 21:20 | 1h 18m | Clean shutdown |
| -42 | Mar 31 21:34 | Apr 01 06:34 | 9h | Overnight — clean or suspend |
| -41 | Apr 01 10:12 | Apr 01 12:26 | 2h 14m | Unknown |
| -40 | Apr 01 12:28 | Apr 01 12:29 | **1 min** | Immediate reboot — likely config test |
| -39 | Apr 01 12:30 | Apr 01 13:03 | 33 min | Unknown |
| -38 | Apr 01 18:57 | Apr 01 20:18 | 1h 21m | Unknown |
| -37 | Apr 02 07:20 | Apr 02 07:33 | 13 min | Short session |
| -36 | Apr 02 18:03 | Apr 02 19:07 | 1h 4m | Unknown |
| -35 | Apr 02 19:35 | Apr 02 20:00 | 25 min | Unknown |
| -34 | Apr 03 09:43 | Apr 03 11:10 | 1h 27m | Unknown |
| -33 | Apr 03 14:56 | Apr 03 19:10 | 4h 14m | Longest stable session (early period) |
| -32 | Apr 04 08:53 | Apr 04 11:18 | 2h 25m | Unknown |
| -31 | Apr 04 12:53 | Apr 04 12:56 | **3 min** | Immediate reboot — config test or crash |
| -30 | Apr 04 13:49 | Apr 04 14:17 | 28 min | Unknown |
| -29 | Apr 04 14:19 | Apr 04 14:32 | 13 min | Unknown |
| -28 | Apr 04 14:32 | Apr 04 17:06 | 2h 34m | Unknown |
| -27 | Apr 04 22:46 | Apr 04 23:01 | 15 min | Short session |
| -26 | Apr 05 11:27 | Apr 05 11:55 | 28 min | Unknown |
| -25 | Apr 05 12:20 | Apr 05 12:30 | 10 min | Short session |
| -24 | Apr 05 20:07 | Apr 05 20:17 | 10 min | Short session |
| -23 | Apr 06 08:54 | Apr 06 08:54 | **<1 min** | Instant crash/reboot |
| -22 | Apr 06 08:55 | Apr 06 09:30 | 35 min | **DMCUB error + flip_done timeout → display freeze → reboot** |
| -21 | Apr 06 09:31 | Apr 06 09:50 | 19 min | nvidia-powerd missing → unknown |
| -20 | Apr 06 09:52 | Apr 06 10:04 | 12 min | kwin output config fail + **watchdog did not stop** → hard reboot |
| -19 | Apr 06 10:05 | Apr 06 10:24 | 19 min | Unknown |
| -18 | Apr 06 10:28 | Apr 06 11:42 | 1h 14m | **iwlwifi firmware crash (ADVANCED_SYSASSERT + NMI_INTERRUPT_LMAC_FATAL)** → kwin fail + **watchdog** → hard reboot |
| -17 | Apr 06 11:46 | Apr 06 17:26 | 5h 40m | **Suspend failure** ("Some devices failed to suspend") + Bluetooth errors + kwin output fail → reboot |
| -16 | Apr 07 09:01 | Apr 07 17:01 | 8h | **Suspend failure** + Bluetooth errors + REAPER coredump + kwin output fail |
| -15 | Apr 08 08:39 | Apr 08 09:30 | 51 min | **Suspend failure** ("Some devices failed to suspend") |
| -14 | Apr 08 09:37 | Apr 08 10:01 | 24 min | Libinput "system too slow" warnings |
| -13 | Apr 08 10:04 | Apr 08 10:37 | 33 min | kwin output fail + **watchdog did not stop** → hard reboot |
| -12 | Apr 08 10:37 | Apr 08 13:06 | 2h 29m | **Suspend failure** + kwin output fail |
| -11 | Apr 08 13:12 | Apr 08 13:13 | **1 min** | Immediate reboot |
| -10 | Apr 08 13:15 | Apr 08 13:43 | 28 min | kwin output fail + **watchdog did not stop** → hard reboot |
| -9 | Apr 08 14:01 | Apr 08 17:41 | 3h 40m | **Suspend failure** + **amdgpu page fault** (Chrome) + **gfx ring timeout/reset** + Chrome coredump |
| -8 | Apr 09 08:31 | Apr 09 13:03 | 4h 32m | Unknown |
| -7 | Apr 09 14:16 | Apr 09 17:29 | 3h 13m | Unknown |
| -6 | Apr 10 07:44 | Apr 10 07:44 | **23 sec** | Boot + immediate clean shutdown (NixOS generation switch) |
| -5 | Apr 10 07:49 | Apr 10 08:53 | 1h 4m | New kernel (6.18.21) — unknown |
| -4 | Apr 10 08:54 | Apr 10 09:33 | 39 min | Unknown |
| -3 | Apr 10 09:33 | Apr 10 14:49 | 5h 16m | Unknown |
| -2 | Apr 10 14:50 | Apr 10 16:51 | 2h 1m | Unknown |
| -1 | Apr 12 11:21 | Apr 12 11:22 | **16 sec** | Clean power off (systemd-poweroff) |
| 0 | Apr 12 16:58 | (running) | — | Current session |

---

## Issue Categories

### 1. amdgpu Display Controller Crashes (CRITICAL)

**Occurrences:** Apr 6 (boot -22), Apr 8 (boot -9)

**Symptoms:**
- `DMCUB error - collecting diagnostic data` (Display MicroController Unit Block)
- `[CRTC:363:crtc-0] flip_done timed out`
- `hw_done or flip_done timed out`
- KWin reports: "Pageflip timed out! This is a bug in the amdgpu kernel driver"
- Display freezes completely, requiring hard reboot

**Apr 8 escalation:** The amdgpu iGPU suffered a page fault triggered by Chrome's GPU process, followed by a `gfx_0.0.0 ring timeout` and GPU ring reset. Chrome coredumped.

**Root cause:** DMCUB firmware issue in the AMD Radeon 780M iGPU, likely triggered during display mode changes (suspend/resume, output reconfiguration). This is a known amdgpu kernel driver bug.

**Mitigation applied:** In the Apr 10 generation, `amdgpu.dcdebugmask=0x10` and `amdgpu.gpu_recovery=1` were added to kernel params.

---

### 2. Suspend/Resume Failures (CRITICAL)

**Occurrences:** Apr 6 (boot -17), Apr 7 (boot -16), Apr 8 (boots -15, -12, -9)

**Message:** `PM: Some devices failed to suspend, or early wake event detected`

**Pattern:** Happens consistently when the system attempts to suspend. The early config used `mem_sleep_default=deep` (S3 sleep), which was changed to `s2idle` (S0ix) in the Apr 10 generation — likely in response to these failures.

**Contributing factors:**
- NVIDIA dGPU may fail to enter D3 during suspend
- PCIe ASPM `powersupersave` policy (changed to `default` in Apr 10)
- The `nvidia.NVreg_UseKernelSuspendNotifiers=1` param was removed in the later config

---

### 3. KWin Wayland Output Configuration Failures (HIGH)

**Occurrences:** Every boot where an external display change or suspend/resume occurs

**Message:** `kwin_wayland: Applying output configuration failed!` (always appears in bursts of 2-4)

**Pattern:** Appears at shutdown/reboot time and after resume from suspend. Often immediately precedes a reboot, suggesting the display stack becomes unrecoverable.

**Correlation:** Frequently co-occurs with the `watchdog: watchdog0: watchdog did not stop!` message, indicating the system was force-rebooted while the display was in a broken state.

---

### 4. Watchdog Hard Reboots (HIGH)

**Occurrences:** Apr 6 (boots -20, -18), Apr 8 (boots -13, -10)

**Message:** `watchdog: watchdog0: watchdog did not stop!`

**Meaning:** The system was rebooted (likely by the user via SysRq or power button) while the hardware watchdog was still running. This confirms the system was in an unresponsive state requiring a forced reboot.

---

### 5. iwlwifi Firmware Crash (MODERATE)

**Occurrence:** Apr 6 (boot -18), ~10:29

**Details:**
- `ADVANCED_SYSASSERT` (error code 0x000013C0)
- `NMI_INTERRUPT_LMAC_FATAL` (error code 0x20000070)
- Firmware: `89.123cf747.0 ty-a0-gf-a0-89.ucode`
- WiFi adapter performed a software reset and recovered

**Impact:** Temporary WiFi disconnection. The adapter self-recovered, but this happened during an already unstable session that ended in a hard reboot.

---

### 6. nvidia-powerd.service Missing (LOW — persistent)

**Occurrences:** Every single boot from Mar 31 onward

**Message:** `Failed to start nvidia-powerd.service: Unit nvidia-powerd.service not found.`

**Cause:** supergfxd tries to start `nvidia-powerd.service` on every boot, but the service unit is not installed in the NixOS configuration. This is a configuration gap — `nvidia-powerd` provides dynamic power management for the dGPU but requires the `nvidia-powerd` package/service to be enabled in NixOS.

**Impact:** The dGPU may not optimally manage power states, potentially contributing to suspend issues and higher idle power draw.

---

### 7. NVIDIA udev Device Node Failures (LOW — persistent)

**Occurrences:** Every boot

**Messages:**
- `nvidia: Process 'bash -c mknod -m 666 /dev/nvidiactl c 195 255' failed with exit code 1`
- `nvidia: Process 'bash -c for i in ... mknod ...' failed with exit code 1`

**Cause:** The NVIDIA udev rules try to create device nodes that already exist. Harmless but noisy.

---

### 8. ACPI BIOS Errors (LOW — persistent, harmless)

**Occurrences:** Every single boot

**Messages:**
- `ACPI BIOS Error: Could not resolve symbol [\_SB.PCI0.GPP2.WWAN], AE_NOT_FOUND`
- `iwlwifi: BIOS contains WGDS but no WRDS`
- `Bluetooth: hci0: No dsm support to set reset delay`
- `acpi device:24: Failed to read mipi-sdw-manager-list: -22`

**Cause:** ASUS BIOS references a WWAN device that doesn't exist in this SKU. The iwlwifi WGDS/WRDS mismatch is a common ASUS BIOS bug. These are cosmetic and do not affect functionality.

---

### 9. Bluetooth Audio Instability (LOW)

**Occurrences:** Apr 6 (boot -17), Apr 7 (boot -16)

**Symptoms:**
- `Rejected connection from !bonded device` (device 88:92:CC:CB:DF:6F)
- `SCO packet for unknown connection handle`
- `corrupted SCO packet`
- PipeWire Bluetooth nodes entering error state

**Cause:** A Bluetooth audio device (likely headphones) repeatedly tries to connect but is not bonded. SCO (voice) packets arrive for non-existent connections. This may be a pairing issue or a device that was previously paired on another OS.

---

### 10. Application Crashes (LOW)

| Date | Application | Cause |
|------|------------|-------|
| Mar 31 19:13 | decent-sampler 1.16.0 | Coredump (audio plugin, likely JACK/PipeWire related) |
| Apr 7 16:41 | REAPER 7.66 (.reaper-wrapped) | Coredump in libSwell.so (`__strncasecmp_evex`) |
| Apr 8 15:06 | Google Chrome 146.0.7680.177 | Coredump after amdgpu page fault + ring timeout |

---

### 11. nouveau GSP Errors (first boot only)

**Occurrence:** Mar 31 (boot -46 only)

**Message:** `nouveau 0000:01:00.0: gsp: ctrl cmd:0x00731341 failed: 0x0000ffff` (repeated ~60 times)

**Cause:** The very first boot used the nouveau driver (open-source) which has poor support for the AD107 (RTX 4060). The system was immediately reconfigured to use the proprietary NVIDIA driver, and this error never appeared again.

---

### 12. Broken Nix Store Path (maestral-gui)

**Occurrences:** Mar 31 (boot -44)

**Message:** `Failed at step EXEC spawning /nix/store/.../maestral-qt-1.9.5/bin/maestral-gui: No such file or directory`

**Cause:** The maestral-gui service references a nix store path that doesn't exist, likely due to a garbage collection or incomplete rebuild.

---

## Stability Timeline Summary

```
Mar 31  ████░░░░░░  Unstable — nouveau→NVIDIA driver migration, 5 reboots
Apr 01  ███░░░░░░░  Moderate — 3 reboots, one 1-min boot (config test)
Apr 02  ██░░░░░░░░  Moderate — 2 reboots
Apr 03  █░░░░░░░░░  Better — 2 boots, one 4h+ session
Apr 04  █████░░░░░  Unstable — 5 reboots, rapid-fire config changes
Apr 05  ███░░░░░░░  Moderate — 3 short sessions
Apr 06  ████████░░  WORST DAY — 8 reboots, DMCUB crash, iwlwifi crash, suspend failures
Apr 07  █░░░░░░░░░  Better — 1 boot, 8h session (but suspend fail + REAPER crash)
Apr 08  ████████░░  WORST DAY (tied) — 8 reboots, amdgpu page fault, watchdog reboots
Apr 09  ██░░░░░░░░  Better — 2 boots, stable sessions
Apr 10  █████░░░░░  NixOS generation switch — 5 boots (config testing)
Apr 11  (no boots)  System was off
Apr 12  ██░░░░░░░░  2 boots, current session running
```

---

## Root Cause Analysis

The system's instability stems from three interacting problems:

1. **amdgpu DMCUB display controller firmware bugs** — The AMD iGPU's display microcontroller crashes during mode changes (suspend/resume, output reconfiguration), causing flip_done timeouts that freeze the display and require hard reboots. This is the primary cause of the watchdog-terminated sessions.

2. **Suspend/resume failure with hybrid GPU** — The combination of `mem_sleep_default=deep` (S3) + `pcie_aspm.policy=powersupersave` + NVIDIA dGPU caused repeated suspend failures. The Apr 10 config change to `s2idle` + `pcie_aspm.policy=default` appears to be an attempt to fix this, but insufficient data exists post-change to confirm improvement.

3. **Missing nvidia-powerd service** — Without dynamic power management, the dGPU may not properly transition power states, contributing to both suspend failures and the DMCUB errors (if the dGPU's power state change triggers a display reconfiguration on the iGPU).

---

## Recommendations

1. **Fix nvidia-powerd:** Add `hardware.nvidia.powerManagement.enable = true;` and ensure `nvidia-powerd` is available as a service. Alternatively, if using supergfxd, configure it to not attempt starting nvidia-powerd.

2. **Monitor post-Apr 10 stability:** The kernel downgrade (6.19.10 → 6.18.21) and new amdgpu params (`gpu_recovery=1`, `dcdebugmask=0x10`) may have addressed the DMCUB crashes. Track whether flip_done timeouts recur.

3. **Consider `amdgpu.dcdebugmask=0x10`:** Already added in the latest config — this disables PSR (Panel Self Refresh) which is a known trigger for DMCUB errors on RDNA 3 iGPUs.

4. **Keep `nvme_core.default_ps_max_latency_us=0`:** Already set. This prevents NVMe APST-related freezes with the Samsung 990 EVO Plus.

5. **Bond or block the rogue Bluetooth device:** Device `88:92:CC:CB:DF:6F` is causing repeated connection rejections and SCO errors. Either pair it properly or blocklist it.

6. **Fix maestral-gui store path:** Run `nixos-rebuild switch` or remove the maestral-gui service if no longer needed.

7. **Update iwlwifi firmware:** The ADVANCED_SYSASSERT crash may be fixed in newer firmware. Check if a newer `linux-firmware` package is available.

---

*Report based on journalctl data from boots -46 through 0 (March 31 – April 12, 2026).*
