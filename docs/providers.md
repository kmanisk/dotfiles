# Provider Abstraction Matrix

This repository abstracts system components behind provider interfaces, allowing the same machine definition logic to configure different backend tools.

---

## Provider Matrix

| Subsystem | Supported Providers | Machine Target | Notes |
|---|---|---|---|
| **Package Manager** | `paru`, `yay`, `pacman`, `scoop`, `winget` | Linux / Windows | Resolved in `run_onchange_install-packages.sh.tmpl` |
| **Greeter / Display Manager** | `ly`, `sddm`, `greetd`, `windows-logon`, `none` | Linux / Windows | Ly preserved in `backups/linux/greeters/ly/` |
| **Login Mode** | `getty-tty1-autologin`, `native` | Linux | Headless TTY1 autologin saves ~150-200MB RAM |
| **Bootloader** | `grub`, `systemd-boot`, `windows-boot-manager` | Linux / Windows | Dual-boot NVMe setup backed up in `backups/` |
| **Network Management** | `networkmanager`, `systemd-networkd`, `windows-net` | Linux / Windows | NetworkManager active on Arch |
| **DNS Resolution** | `systemd-resolved`, `dnsmasq`, `windows-dns` | Linux / Windows | Caching stub resolver at 127.0.0.53 |
| **Key Remapping** | `user-service`, `system-service`, `none` | Linux | Managed by `xremap-hypr-bin` via user systemd unit |
| **GPU Strategy** | `hybrid-optimus-d3cold`, `direct`, `intel-only` | Linux / Windows | Intel iGPU session + NVIDIA D3cold suspend |
| **Audio Engine** | `pipewire-rnnoise`, `pipewire-standard`, `wasapi` | Linux / Windows | Dusky Audio Studio headless PipeWire filter |

---

## Provider Contracts

### 1. Package Manager Provider
- Must support automated non-interactive batch installation (`--needed --noconfirm` or equivalent).
- Must respect pre-update safety snapshots on Btrfs systems.

### 2. GPU Strategy Provider
- On `hybrid-optimus-d3cold`:
  - Compositor and session MUST run on the Intel iGPU (`LIBVA_DRIVER_NAME=iHD`).
  - dGPU stays in `suspended` runtime state (0 W) until explicitly offloaded via `prime-run` or `gamemoderun`.
  - Multi-GPU explicit fence race condition avoided via `AQ_MGPU_NO_EXPLICIT=1` in `gpu.lua`.

### 3. Audio Provider
- On `pipewire-rnnoise`:
  - Must run headlessly in background without requiring open GUI windows.
  - Low-latency real-time thread priority configured via `realtime-privileges`.
