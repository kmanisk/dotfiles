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
| **`asus-tuf-f16`** | CachyOS Linux (x86-64-v3) | ASUS TUF Gaming F16 Laptop | Hybrid Optimus (iGPU + RTX 5050), Paru, Headless Getty Autologin (Ly standby), Grub, PipeWire RNNoise DSP, Gaming |
| **`windows-workstation`** | Windows 11 Pro | Custom Gaming / Dev Workstation | Scoop, Windows Boot Manager, Wasapi, Gaming, Development |
| **`generic-linux`** | Arch Linux / Derivative | Generic Portable Fallback | Pacman, Grub, NetworkManager, Hyprland |

---

## Dynamic State Reconciliation

Unlike systems with one-time setup scripts, this repository uses **declarative state reconcilers** executed automatically on data or template change:
- **`run_onchange_linux-00-reconcile-packages.sh.tmpl`**: Reconciles system & AUR packages using safe bash arrays (`paru`, `yay`, or `pacman`), with automatic Snapper pre-update snapshot hooks and dry-run execution modes.
- **`run_onchange_linux-10-reconcile-login.sh.tmpl`**: Reconciles login and display managers (e.g. configuring headless TTY1 autologin while cleanly retiring Ly, SDDM, or GDM to avoid terminal contention).
- **`run_onchange_linux-20-reconcile-services.sh.tmpl`**: Reconciles systemd system and user daemons (Bluetooth, ASUS WMI, Snapper cleanup timers, XRemap user services, and Hyprland desktop units). When features or providers are toggled, inactive services are cleanly stopped, disabled, and retired.

---

## Verification Tooling

The repository provides a comprehensive suite of 7 dedicated test runners in `scripts/verify/`:

| Suite | Script | Scope | Checks | Status |
|---|---|---|---|---|
| **1. Architecture & Boundaries** | [`scripts/verify/architecture.sh`](scripts/verify/architecture.sh) | Schema validation, single-source hardware deduplication, generic fallback | 21/21 Passing | Verified |
| **2. Machine Profiles Matrix** | [`scripts/verify/profiles.sh`](scripts/verify/profiles.sh) | Cross-machine template compilation (`asus-tuf-f16`, `windows-workstation`, `generic-linux`) | 12/12 Passing | Verified |
| **3. Provider Abstractions** | [`scripts/verify/providers.sh`](scripts/verify/providers.sh) | Package managers, login modes, XRemap user services, browser secret stores, bootloader boundary | 13/13 Passing | Verified |
| **4. Package Manifest Closure** | [`scripts/verify/packages.sh`](scripts/verify/packages.sh) | Duplicate detection, non-empty package sets, AUR isolation, snapshot exclusion | 22/22 Passing | Verified |
| **5. Service Reconciliation** | [`scripts/verify/services.sh`](scripts/verify/services.sh) | Bi-directional lifecycle (enable desired / retire disabled), dry-run guards, bash syntax | 14/14 Passing | Verified |
| **6. Security & Secret Boundaries** | [`scripts/verify/security.sh`](scripts/verify/security.sh) | Working tree & git history (`git log -p`) secret scanning, Age crypto configuration, directory isolation | 18/18 Passing | Verified |
| **7. Live Host Runtime Health** | [`scripts/verify/health.sh`](scripts/verify/health.sh) | Live GPU D3cold, Intel iGPU, PipeWire RNNoise voice DSP, systemd timers, ASUS WMI | 18/18 Passing | Live Host (CachyOS) |
| **Master Verification Runner** | [`scripts/verify/system.sh`](scripts/verify/system.sh) | Sequentially executes all 7 suites and reports consolidated telemetry | **118/118 Passing** | **100% Pass** |

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

# 4. Verify system reproducibility and host health
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

## Documentation Index

- [Architecture & Layer Design](docs/architecture.md): The 6-layer model, reconciliation contracts, and firmware boundaries.
- [Bootstrap Guide](docs/bootstrap.md): Complete setup procedures for fresh machines.
- [Machine Profiles](docs/machines.md): Hardware specifications and instructions for adding new devices.
- [Provider Matrix](docs/providers.md): Abstraction matrix, browser keyring autologin isolation, and contracts.
- [Package Manifests](packages/README.md): Declarative package sets vs. audit snapshots.
- [Feature Flags](docs/features.md): Modular flags for gaming, development, ASUS control, and Snapper.
- [Disaster Recovery](docs/recovery.md): Restoring Ly display manager fallback, rolling back Btrfs snapshots, and recovering configs.
- [Hardware Audit & Platform Quirks](docs/audit.md): Hybrid GPU power management, Mesa explicit sync workarounds, and telemetry.
