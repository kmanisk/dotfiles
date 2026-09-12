# Modular Cross-Platform Workstation Dotfiles

Fully reproducible, modular, multi-tier workstation architecture for **Linux** (CachyOS / Arch / Hyprland) and **Windows 11** environments, managed with [chezmoi](https://www.chezmoi.io/) and encrypted with [age](https://github.com/FiloSottile/age).

---

## 6-Layer Architectural Composition Model

Every configuration artifact is evaluated and composed through six distinct layers:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. COMMON CONFIGURATION                                      │
│    Git identity, cross-platform CLI tools, editor bases     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 2. OS-SPECIFIC CONFIGURATION                                 │
│    Linux (dot_config, systemd)  │  Windows (AppData, Scoop) │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 3. MACHINE-SPECIFIC CONFIGURATION                           │
│    ASUS TUF Gaming F16         │  Windows Workstation PC    │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 4. HARDWARE-SPECIFIC CONFIGURATION                           │
│    Optimus (Intel iGPU + RTX 5050 Mobile), Btrfs Subvolumes │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 5. PROVIDER-SPECIFIC CONFIGURATION                           │
│    Package Mgr (paru/scoop), Bootloader, Greeter, Audio DSP │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 6. OPTIONAL FEATURES                                         │
│    Gaming stack, development runtimes, ASUS WMI, Snapper    │
└─────────────────────────────────────────────────────────────┘
```

---

## Machine Fleet

| Machine Identifier | Operating System | Chassis / Purpose | Key Providers & Features |
|---|---|---|---|
| **`asus-tuf-f16`** | CachyOS Linux (x86-64-v3) | ASUS TUF Gaming F16 Laptop | Hybrid Optimus (iGPU + RTX 5050), Paru, Headless Getty Autologin, Grub, PipeWire RNNoise DSP, Gaming |
| **`windows-workstation`** | Windows 11 Pro | Custom Gaming / Dev Workstation | Scoop, Windows Boot Manager, Wasapi, Gaming, Development |
| **`generic-linux`** | Arch Linux / Derivative | Generic Portable Fallback | Pacman, Grub, NetworkManager, Hyprland |

---

## Quickstart Provisioning

### Linux (CachyOS / Arch Linux)
```bash
# 1. Ensure core tools
sudo pacman -Syu --needed git base-devel chezmoi

# 2. Place your age private key (if managing encrypted secrets)
mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi
cp /path/to/key.txt ~/.config/chezmoi/key.txt && chmod 600 ~/.config/chezmoi/key.txt

# 3. Initialize and apply
chezmoi init --apply https://github.com/kmanisk/dotfiles.git

# 4. Verify system health
~/.local/share/chezmoi/scripts/verify/system.sh
```

### Windows 11 (PowerShell)
```powershell
# 1. Allow script execution
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Run bootstrap installer
iwr -useb https://raw.githubusercontent.com/kmanisk/dotfiles/master/scripts/bootstrap/windows.ps1 | iex
```

---

## Daily Operations

| Command | Description |
|---|---|
| `chezmoi diff` | Show pending differences against local machine state |
| `chezmoi apply` | Safely apply repository configuration to host |
| `chezmoi update` | Pull remote git updates and apply cleanly |
| `chezmoi add <path>` | Track a new configuration file |
| `chezmoi add --encrypt <path>` | Track a file with Age ASCII-armored encryption |
| `~/.local/share/chezmoi/scripts/verify/system.sh` | Run automated 18-point system health verification |
| `~/.local/share/chezmoi/scripts/audit/system-report.sh` | Generate comprehensive, sanitized hardware & service report |

---

## Documentation Index

- [Architecture & Layer Design](docs/architecture.md): In-depth breakdown of the 6-layer model.
- [Bootstrap Guide](docs/bootstrap.md): Complete setup procedures for fresh machines.
- [Machine Profiles](docs/machines.md): Hardware specifications and instructions for adding new devices.
- [Provider Matrix](docs/providers.md): Abstraction matrix for package managers, greeters, bootloaders, and audio.
- [Feature Flags](docs/features.md): Modular flags for gaming, development, ASUS control, and Snapper.
- [Disaster Recovery](docs/recovery.md): Restoring Ly display manager, rolling back Btrfs snapshots, and recovering configs.
- [Hardware Audit & Platform Quirks](docs/audit.md): Hybrid GPU power management, Mesa explicit sync workarounds, and telemetry.
