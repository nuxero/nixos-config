# Current State & Next Steps — ASUS ROG Zephyrus G14 (GA402)

**Date:** April 12, 2026
**Sources cross-referenced:**
- [System Stability Report](nixos-g14-system-report.md) — journalctl analysis, Mar 31 – Apr 12
- [Fixes Implemented](nixos-g14-fixes-implemented.md) — git history of applied changes
- [ROG Zephyrus Guide](nixos-rog-zephyrus-guide.md) — best practices and known issues
- [nixos-hardware `ga402x/shared.nix`](https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga402x/shared.nix) — upstream hardware module
- Community sources (NixOS Discourse, Arch Wiki, NVIDIA docs, kernel CVE trackers)

---

## Current Configuration State

The system has gone through two NixOS generations in 13 days. The current (Apr 10+) configuration represents a significant departure from both the initial setup and the guide's generic recommendations.

### Where the config diverges from the guide

| Setting | Guide recommends | Current config | Why it changed |
|---------|-----------------|----------------|----------------|
| Kernel | `linuxPackages_latest` | `linuxPackages` (LTS) | Latest kernel (6.19.10) had worse NVIDIA stability; LTS (6.18.21) chosen for proprietary driver compat |
| `hardware.nvidia.open` | `true` | `false` | Open kernel modules have broken GSP firmware on RTX 4060 Laptop (AD107) — heartbeat timeouts, sync floods |
| `powerManagement.finegrained` | `true` | `false` | Conflicts with supergfxd's own RTD3 management; having both caused GSP firmware crashes |
| `nvidia.NVreg_EnableGpuFirmware` | not mentioned | `=0` (disabled) | GSP firmware never fully initializes on this GPU, causing heartbeat timeouts |
| `mem_sleep_default` | not mentioned | `s2idle` (overrides `deep` from nixos-hardware) | S3 deep sleep caused repeated suspend failures with hybrid GPU |
| `pcie_aspm.policy` | not mentioned | `default` (overrides `powersupersave` from nixos-hardware) | Aggressive ASPM caused NVIDIA GPU crashes |
| `amdgpu.dcdebugmask` | not mentioned | `0x10` (PSR disabled) | DMCUB firmware crashes triggered by Panel Self Refresh on RDNA 3 iGPU |
| NVMe APST | `=5500` (throttled) | `=0` (fully disabled) | Samsung 990 EVO Plus controller resets required complete APST disable |
| `GBM_BACKEND` / `__GLX_VENDOR_LIBRARY_NAME` | listed in session vars | not set globally | Correctly omitted — guide itself warns these break hybrid iGPU setups |

These divergences are all justified by the real-world issues documented in the system report. The guide should be updated to reflect these findings (see [Guide Corrections](#guide-corrections-needed) below).

### What nixos-hardware `shared.nix` does upstream

The imported module `asus-zephyrus-ga402x-amdgpu` pulls in [`ga402x/shared.nix`](https://github.com/NixOS/nixos-hardware/blob/master/asus/zephyrus/ga402x/shared.nix), which unconditionally sets:

```nix
boot.kernelParams = [
  "mem_sleep_default=deep"
  "pcie_aspm.policy=powersupersave"
];
```

The current config correctly overrides both by appending its own values (last value wins for duplicate kernel params). This is a known conflict — the upstream module's aggressive power settings are problematic for NVIDIA hybrid configurations on this hardware.

---

## Issue Status Matrix

Combining the system report's 12 issue categories with the fixes document and current config:

| # | Issue | Severity | Status | Confidence | Detail |
|---|-------|----------|--------|------------|--------|
| 1 | amdgpu DMCUB display crashes | CRITICAL | Mitigated | Medium | PSR disabled (`dcdebugmask=0x10`), GPU recovery enabled, GFXOFF disabled, LTS kernel. The upstream kernel also received a fix for CVE-2024-47662 (DMCUB diagnostic register read causing hangs on DCN3.5). Only 2 days of post-fix data — needs monitoring. |
| 2 | Suspend/resume failures | CRITICAL | Mitigated | Medium | Switched to `s2idle`, relaxed ASPM, disabled finegrained PM, disabled GSP firmware. No suspend failures observed post-Apr 10, but limited data (system was off Apr 11, only 2 boots Apr 12). |
| 3 | KWin Wayland output failures | HIGH | Partially fixed | Low | `nvidia_modeset.vblank_sem_control=0` addresses post-resume black screens. The underlying KWin output reconfiguration failures may still occur — they're tied to the display stack recovering from GPU state changes. |
| 4 | Watchdog hard reboots | HIGH | Indirectly addressed | Medium | These were symptoms of §1/§2/§3. No watchdog events post-Apr 10. |
| 5 | iwlwifi firmware crash | MODERATE | Unaddressed | — | Single occurrence, self-recovered. The flake update on Apr 10 may have pulled newer `linux-firmware`. Low priority unless it recurs. |
| 6 | nvidia-powerd missing | LOW | **Unaddressed** | — | supergfxd still logs `Failed to start nvidia-powerd.service` every boot. See [Next Steps](#next-steps). |
| 7 | NVIDIA udev device node failures | LOW | Unaddressed | — | Cosmetic. Harmless race condition in NVIDIA udev rules. |
| 8 | ACPI BIOS errors | LOW | Not fixable | — | ASUS BIOS bugs (WWAN reference, WGDS/WRDS mismatch). Cosmetic. |
| 9 | Bluetooth audio instability | LOW | Partially addressed | Low | Bluetooth daemon enabled via feature module. Rogue device `88:92:CC:CB:DF:6F` still not bonded or blocklisted. |
| 10 | Application crashes | LOW | Indirectly addressed | Medium | REAPER and Chrome crashes were downstream of GPU issues (§1, §9). Decent Sampler crash was likely PipeWire/JACK related. |
| 11 | nouveau GSP errors | LOW | Fixed | High | Resolved on day 1 by switching to proprietary NVIDIA driver. |
| 12 | Broken maestral-gui store path | LOW | Fixed | High | Full Nix store path + correct binary name (`maestral_qt`). |

---

## Stability Assessment

### Pre-fix period (Mar 31 – Apr 9): Severe instability
- 42 boots in 10 days (4.2/day)
- Two days with 8 reboots each (Apr 6, Apr 8)
- Multiple hard reboots (watchdog), display freezes, suspend failures
- Longest stable session: 9h (overnight, likely suspended)

### Post-fix period (Apr 10 – Apr 12): Insufficient data
- 5 boots on Apr 10 (config testing — expected)
- System off Apr 11
- 2 boots on Apr 12 (one clean power-off, one current session)
- No DMCUB errors, no suspend failures, no watchdog events observed
- **Verdict: Promising but unconfirmed.** Need at least a full week of normal use with suspend/resume cycles to declare stability.

---

## Next Steps

Ordered by impact and urgency.

### 1. Observe — Confirm post-Apr 10 stability (this week)

The most important thing right now is data. Use the system normally for a week, including:
- Multiple suspend/resume cycles (lid close, manual suspend)
- External display connect/disconnect
- GPU-intensive workloads (gaming, Chrome with hardware acceleration)

Check for regressions:
```bash
# After a few days of use:
journalctl -b -p err --grep="DMCUB\|flip_done\|watchdog\|failed to suspend"
```

If no DMCUB or suspend errors appear after a week of normal use, the critical issues can be considered resolved.

### 2. Fix — Silence the nvidia-powerd spam

Every boot logs `Failed to start nvidia-powerd.service`. There are two approaches:

**Option A: Enable nvidia-powerd (recommended if dGPU is used frequently)**

`nvidia-powerd` provides dynamic power balancing between CPU and GPU. On NixOS, this is controlled by `hardware.nvidia.dynamicBoost.enable`:

```nix
# In features/hardware/asus-nvidia/system.nix
hardware.nvidia.dynamicBoost.enable = true;
```

This enables the `nvidia-powerd` systemd service. Note: `nvidia-powerd` requires the proprietary driver (already in use) and works best on AC power.

**Option B: Tell supergfxd to stop trying to start it**

If you don't need dynamic boost (e.g., dGPU is rarely used), configure supergfxd to not manage nvidia-powerd. Check `/etc/supergfxd.conf` or the asusd configuration for the relevant toggle.

### 3. Fix — Blocklist the rogue Bluetooth device

Device `88:92:CC:CB:DF:6F` causes repeated connection rejections and corrupted SCO packets. Either pair it properly or block it:

```bash
# Identify the device
bluetoothctl info 88:92:CC:CB:DF:6F

# If it's unwanted, block it
bluetoothctl block 88:92:CC:CB:DF:6F
```

Or add it to the Bluetooth blocklist persistently via the Bluetooth config.

### 4. Consider — Contribute overrides back to nixos-hardware

The `ga402x/shared.nix` upstream module sets `mem_sleep_default=deep` and `pcie_aspm.policy=powersupersave` unconditionally. These are problematic for NVIDIA hybrid configurations. Consider opening a PR or issue on [NixOS/nixos-hardware](https://github.com/NixOS/nixos-hardware) to:
- Make these params conditional on whether the NVIDIA dGPU is active
- Or at minimum, document the conflict in the module comments
- Reference CVE-2024-47662 for the DMCUB issue context

### 5. Consider — Update the guide to match reality

Several guide recommendations turned out to be wrong or incomplete for this specific hardware. See the corrections section below.

### 6. Low priority — Monitor iwlwifi firmware

The single `ADVANCED_SYSASSERT` crash on Apr 6 self-recovered. If WiFi drops become frequent:
```bash
# Check current firmware version
dmesg | grep iwlwifi | grep "loaded firmware"

# Check if newer firmware is available in the current nixpkgs
nix eval nixpkgs#linux-firmware.version
```

### 7. Low priority — SSD firmware

The Samsung 990 EVO Plus NVMe APST issue is worked around with `nvme_core.default_ps_max_latency_us=0`, but this disables all NVMe power saving. Samsung may have released a firmware update that fixes the controller reset issue. Check:
```bash
sudo smartctl -a /dev/nvme0n1 | grep "Firmware"
# Compare against Samsung's latest firmware release notes
fwupdmgr get-devices  # check if LVFS has an update
```

If a firmware update is available, applying it could allow re-enabling APST (with a conservative latency value like `5500` instead of `0`), improving battery life.

---

## Guide Corrections Needed

The ROG Zephyrus guide contains several recommendations that conflict with what was learned from the system report. These should be updated:

| Section | Current guide text | Should say |
|---------|-------------------|------------|
| NVIDIA driver | Recommends `open = true` for RTX 40-series | Add caveat: RTX 4060 Laptop (AD107) has broken GSP with open modules — use `open = false` and `NVreg_EnableGpuFirmware=0` if experiencing heartbeat timeouts or sync floods |
| Power management | Recommends `finegrained = true` | Add caveat: if using supergfxd, set `finegrained = false` — supergfxd manages RTD3 independently and the two conflict |
| NVMe APST | Recommends `=5500` | Note that Samsung 990 EVO Plus may require `=0` (full disable) if `=5500` still causes controller resets |
| Known issues | Suspend/resume crash workaround: "ensure powerManagement.enable" | Add: on GA402X with NVIDIA hybrid, also override nixos-hardware's `mem_sleep_default=deep` to `s2idle` and `pcie_aspm.policy=powersupersave` to `default` |
| Best practices §4 | "Prefer the open kernel module" | Qualify: this depends on the specific GPU. AD107 (RTX 4060 Laptop) works better with proprietary modules as of driver 595.x |
| Minimal example | Uses `finegrained = true`, `open = true`, `linuxPackages_latest` | Add a variant for GA402X with NVIDIA showing the tested-stable config |

---

## Summary

The system went from severe instability (47 boots in 13 days) to what appears to be a stable configuration after the Apr 10 overhaul. The key fixes were: switching to LTS kernel, disabling PSR on the AMD iGPU, switching to proprietary NVIDIA modules with GSP firmware disabled, moving from S3 to s2idle sleep, and relaxing PCIe ASPM. The remaining open items are low-severity (nvidia-powerd spam, rogue Bluetooth device, NVMe firmware). The most important next step is simply using the system normally for a week to confirm the fixes are holding.
