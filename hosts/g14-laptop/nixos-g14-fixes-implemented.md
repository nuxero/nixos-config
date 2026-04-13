# Fixes Implemented — ASUS ROG Zephyrus G14 (GA402)

**Reference:** [nixos-g14-system-report.md](nixos-g14-system-report.md)
**Period:** March 31 – April 12, 2026
**Generated:** April 12, 2026

---

## Fix Timeline

### Mar 31 — Initial Configuration (`ddfe195`)

Set up the NVIDIA proprietary driver stack after the first boot failed on nouveau (Report §11). Initial config used `open = true` (open kernel modules) and `powerManagement.finegrained = true`.

**File:** `features/hardware/asus-nvidia.nix` (later refactored to `features/hardware/asus-nvidia/system.nix`)

---

### Apr 2 — Maestral Autostart Path Fix (`2410c76`)

**Report issue:** §12 — Broken Nix Store Path (maestral-gui)

The maestral-gui autostart `.desktop` entry used a bare `Exec=maestral-gui` which resolved to a broken store path. Fixed by using the full Nix store path `${pkgs.maestral-gui}/bin/maestral-gui` with a 5-second startup delay.

```nix
# Before
Exec=maestral-gui

# After
Exec=${pkgs.bash}/bin/bash -c "sleep 5 && ${pkgs.maestral-gui}/bin/maestral-gui"
```

**File:** `features/apps/work-dev.nix`

---

### Apr 3 — Maestral Binary Name Correction (`7d193e8`, `543bef6`)

**Report issue:** §12 — Broken Nix Store Path (maestral-gui)

Two follow-up commits corrected the actual binary name inside the maestral-gui package: `maestral-gui` → `maestral-qt` → `maestral_qt`.

**File:** `features/apps/work-dev.nix`

---

### Apr 3 — Bluetooth Feature Added (`7d193e8`)

**Report issue:** §9 — Bluetooth Audio Instability

Added a dedicated Bluetooth feature module enabling `hardware.bluetooth.enable` and `hardware.bluetooth.powerOnBoot`. This gave the system proper Bluetooth daemon management rather than relying on defaults.

**File:** `features/hardware/bluetooth.nix` (new), `hosts/g14-laptop/configuration.nix`

---

### Apr 6 — First Round of GPU Crash Fixes (`cc43d1b`)

**Report issues:** §1 (amdgpu DMCUB crashes), §2 (Suspend failures), §3 (KWin output failures)

This was the first targeted response to the critical GPU instability. Three kernel params were added and the NVIDIA power management config was changed:

| Change | Rationale |
|--------|-----------|
| `pcie_aspm.policy=default` | Override `powersupersave` set by nixos-hardware — NVIDIA GPUs crash with aggressive ASPM |
| `mem_sleep_default=s2idle` | Override `deep` (S3) — avoids amdgpu DMCUB errors on suspend |
| `amdgpu.dcdebugmask=0x10` | Disable Panel Self Refresh (PSR) — known trigger for DMCUB errors on RDNA 3 |
| `powerManagement.finegrained = false` | supergfxd handles RTD3 power management; having both NixOS finegrained + supergfxd caused GSP firmware crashes |

**Commit:** `cc43d1b` — "fix for nvidia crashes"
**File:** `features/hardware/asus-nvidia/system.nix`

---

### Apr 8 — NVIDIA Driver Module Switch + GSP Fixes (`5a767bb`)

**Report issues:** §1 (amdgpu crashes), §3 (KWin output failures), §4 (Watchdog hard reboots)

After continued instability on Apr 6–8 (the two worst days), the NVIDIA driver was switched from open to proprietary kernel modules and additional kernel params were added:

| Change | Rationale |
|--------|-----------|
| `open = false` | Open kernel modules have broken GSP on RTX 4060 Laptop (AD107) |
| `nvidia.NVreg_EnableGpuFirmware=0` | Disable GSP firmware — it never fully initializes on this GPU, causing heartbeat timeouts and sync floods |
| `nvidia_modeset.vblank_sem_control=0` | Fix KWin Wayland black screen / cursor-only after suspend resume |
| `pcie_ports=native` | Diagnostic: force kernel AER driver to log PCIe errors to identify sync flood source |

**Commit:** `5a767bb` — "fixing some issues with nvidia card"
**File:** `features/hardware/asus-nvidia/system.nix`

---

### Apr 9 — NVMe APST Disabled (`2089b22`)

**Report issue:** Related to overall system freezes — Samsung 990 EVO Plus NVMe controller resets

Added `nvme_core.default_ps_max_latency_us=0` to disable NVMe Autonomous Power State Transitions (APST), which can cause controller resets and system freezes on the Samsung 990 EVO Plus.

```nix
boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" ];
```

**Commit:** `2089b22` — "disable nvme apst to prevent controller resets on samsung drive"
**File:** `hosts/g14-laptop/configuration.nix`

---

### Apr 10 — Major Stabilization Overhaul (`901286d`)

**Report issues:** §1, §2, §3, §4 — all critical/high issues

This commit consolidated all kernel params into `asus-nvidia/system.nix`, switched to the LTS kernel, and added amdgpu recovery params. This corresponds to the NixOS generation switch visible in the report's boot timeline (boot -6 onward).

| Change | Rationale |
|--------|-----------|
| `boot.kernelPackages = pkgs.linuxPackages` | Switch from latest (6.19.10) to LTS (6.18.21) — more stable with NVIDIA proprietary drivers |
| `amdgpu.gpu_recovery=1` | Force GPU reset on ring timeout instead of escalating to sync flood |
| `amdgpu.ppfeaturemask=0xfffd3fff` | Disable GFXOFF (bit 13) — prevents gfx ring hangs on the AMD iGPU |
| `nvme_core.default_ps_max_latency_us=0` | Moved from `configuration.nix` into the shared hardware module |
| `services.smartd.enable = true` | Added NVMe health monitoring via smartd |

**Commit:** `901286d` — "more potential fixes to crashes"
**Files:** `features/hardware/asus-nvidia/system.nix`, `hosts/g14-laptop/configuration.nix`

---

### Apr 10 — Diagnostic Param Removed + Flake Update (`defaa98`)

Removed `pcie_ports=native` (the diagnostic AER logging param) and updated the flake lock (nixpkgs + home-manager).

**Commit:** `defaa98` — "update and remove potentially problematic kernel param"
**File:** `features/hardware/asus-nvidia/system.nix`, `flake.lock`

---

## Report Issues vs. Fix Status

| # | Issue | Severity | Fix Status | Commit(s) |
|---|-------|----------|------------|-----------|
| 1 | amdgpu DMCUB display crashes | CRITICAL | Mitigated — PSR disabled, GPU recovery enabled, GFXOFF disabled, LTS kernel | `cc43d1b`, `901286d` |
| 2 | Suspend/resume failures | CRITICAL | Mitigated — switched to s2idle, relaxed ASPM, fixed NVIDIA power mgmt | `cc43d1b`, `5a767bb`, `901286d` |
| 3 | KWin Wayland output failures | HIGH | Partially fixed — vblank_sem_control=0 added | `5a767bb` |
| 4 | Watchdog hard reboots | HIGH | Indirectly addressed — root causes (§1, §2, §3) were targeted | `cc43d1b`, `5a767bb`, `901286d` |
| 5 | iwlwifi firmware crash | MODERATE | Not directly addressed — single occurrence, self-recovered |  |
| 6 | nvidia-powerd missing | LOW | Not fixed — supergfxd still tries to start it every boot |  |
| 7 | NVIDIA udev device node failures | LOW | Not fixed — cosmetic, harmless |  |
| 8 | ACPI BIOS errors | LOW | Not fixable — ASUS BIOS bugs, cosmetic |  |
| 9 | Bluetooth audio instability | LOW | Partially addressed — Bluetooth feature module added | `7d193e8` |
| 10 | Application crashes | LOW | Not directly addressed — downstream of GPU issues |  |
| 11 | nouveau GSP errors | LOW | Fixed — switched to proprietary NVIDIA driver on Mar 31 | `ddfe195` |
| 12 | Broken maestral-gui store path | LOW | Fixed — full Nix store path + correct binary name | `2410c76`, `7d193e8`, `543bef6` |

---

## Still Open

- `nvidia-powerd.service` is still missing (Report §6). The report recommends adding `hardware.nvidia.powerManagement.enable = true` (already set) and ensuring the `nvidia-powerd` package/service is available, or configuring supergfxd to stop attempting to start it.
- The rogue Bluetooth device (`88:92:CC:CB:DF:6F`) has not been bonded or blocklisted (Report §9).
- iwlwifi firmware has not been explicitly updated (Report §5), though the flake update on Apr 10 may have pulled a newer `linux-firmware`.
- Post-Apr 10 stability data is limited (only 4 days, 2 with boots) — not enough to confirm whether the DMCUB and suspend fixes are holding.
