# Machine Profiles & Hardware Definitions

This repository treats physical and virtual workstations as declared machine targets in `.chezmoidata.toml`.

---

## Existing Profiles

### 1. `asus-tuf-f16` (Primary Linux Gaming Laptop)
- **Chassis:** ASUS TUF Gaming F16 (FX608J)
- **OS:** CachyOS Linux (x86-64-v3, BORE scheduler)
- **Display:** 16:10 1920x1200 @ 165Hz (internal `eDP-1`, VRR fullscreen)
- **CPUs:** 13th Gen Intel Core i5-13450HX (6 Performance Cores + 4 Efficient Cores, 16 Threads)
- **Graphics Pipeline:**
  - Intel Raptor Lake-S UHD Graphics (`iHD` VA-API driver) for desktop session and 2D.
  - NVIDIA GeForce RTX 5050 Mobile (GB207M, 8GB GDDR6) suspended in D3cold runtime power management (0W idle).
  - Explicit PRIME render offload: `gamemoderun prime-run %command%`
- **Filesystem:** Btrfs on NVMe with Snapper snapshot hooks and selective No-CoW for Steam/Wine directories.
- **Audio:** PipeWire + WirePlumber + Headless Dusky RNNoise Voice DSP engine.
- **Greeter:** Headless systemd TTY1 getty autologin into Hyprland (0 MB display manager overhead), with Ly preserved in `backups/`.

### 2. `windows-workstation` (Windows 11 Workstation)
- **OS:** Windows 11 Pro 64-bit
- **Shell:** PowerShell 7 / Clink / Windows Terminal
- **Package Manager:** Scoop
- **Paths Managed:** `AppData/Local`, `AppData/Roaming`, `readonly_Documents/` (game configs/saves), `scoop/` buckets.

### 3. `generic-linux` (Portable Fallback)
- **OS:** Generic Arch Linux or derivative
- **Scope:** Baseline system configuration for any standard Linux machine without ASUS or dual-GPU specifics.

---

## How to Add a New Machine

To add a new machine to the fleet:

1. **Add definition to `.chezmoidata.toml`:**
   ```toml
   [machines.my-thinkpad]
   description = "Lenovo ThinkPad X1 Carbon"
   os = "linux"
   distribution = "arch"
   hardware_profile = "thinkpad-x1"

   [hardware.thinkpad-x1]
   type = "laptop"
   cpu_vendor = "intel"
   gpu_strategy = "intel-only"
   display_primary = "eDP-1"
   display_resolution = "2880x1800@90Hz"
   display_scale = "2.0"
   filesystem = "btrfs"

   [machines.my-thinkpad.providers]
   package_manager = "paru"
   greeter = "ly"
   login_mode = "native"
   bootloader = "systemd-boot"
   network = "networkmanager"
   dns = "systemd-resolved"
   xremap = "user-service"
   audio = "pipewire-standard"
   browser_secret_store = "basic"

   [machines.my-thinkpad.features]
   gaming = false
   development = true
   asus_ctl = false
   bluetooth = true
   hyprland = true
   snapper = true
   hdr = false
   tearing_opt = false
   ```

2. **Deploy onto the machine:**
   ```bash
   chezmoi init --apply https://github.com/kmanisk/dotfiles.git
   ```
   *Select `my-thinkpad` when prompted.*
