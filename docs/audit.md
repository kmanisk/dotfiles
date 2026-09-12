# System Hardware Audit & Platform Quirks

This document records the hardware audit, power profiling, and driver workarounds verified on the primary Linux workstation (`asus-tuf-f16`).

---

## Hardware Profile

| Component | Specification | Operational Configuration |
|---|---|---|
| **Chassis** | ASUS TUF Gaming F16 (FX608J Family) | Battery threshold 60%, Balanced profile via `asusctl` |
| **CPU** | Intel Core i5-13450HX (10 cores: 6P + 4E, 16 threads) | `powersave` governor with `intel_pstate`, BORE kernel scheduler |
| **Integrated GPU** | Intel Raptor Lake-S UHD Graphics [8086:a78b] | Drives Wayland compositor via `i915`, `LIBVA_DRIVER_NAME=iHD` |
| **Discrete GPU** | NVIDIA GeForce RTX 5050 Mobile [10de:2dd8] (8GB GDDR6) | Suspended in D3cold (0 W idle). Offloaded via `prime-run` |
| **Internal Panel** | 16:10 1920x1200 @ 165Hz (Connector: `eDP-1`) | Native scanout, VRR enabled for fullscreen applications |
| **Storage** | 1TB NVMe (Partition 6: Btrfs) | Subvolumes: `@`, `@home`, `@snapshots`, `@var_log`, etc. |
| **Audio** | Realtek ALC256 + BlueZ 5 (Soundcore Q20i) | PipeWire + WirePlumber (stock) |

---

## Critical Platform Workarounds

### 1. Dual-GPU Power Management (D3cold)
- **Design:** Session runs 100% on the Intel iGPU. The RTX 5050 stays suspended in `D3cold` runtime state consuming 0 W until a 3D application starts.
- **Verification:**
  ```bash
  cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status
  # Returns 'suspended' at idle, 'active' during games
  ```
- **CS2 Execution:** Steam launches game via `gamemoderun %command% -w 1440 -h 1080 -vulkan` or `cs2-launch` with verified 4.3 GB VRAM allocation directly on the RTX 5050.

### 2. Audio Pipeline
- **Design:** Stock PipeWire + WirePlumber, no DSP daemon.

### 3. Headless Getty Autologin
- **Design:** Systemd override on `/etc/systemd/system/getty@tty1.service.d/override.conf` executes autologin on TTY1 directly into `fish`, which executes `startx` (i3/X11).
- **Advantage:** Eliminates graphical display manager overhead, saving 150–200 MB background RAM and accelerating boot time.
