# Cross-Platform Workstation Architecture

This repository defines a modular, multi-tier workstation architecture managed entirely through [chezmoi](https://www.chezmoi.io/). It provides a single source of truth for both Linux (CachyOS / Arch / Hyprland) and Windows 11 workstations without fragmentation or platform dilution.

---

## The 6-Layer Composition Model

Every configuration artifact is evaluated through six composable layers:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. COMMON CONFIGURATION                                      │
│    Git configs, basic shell tools, common CLI utilities     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 2. OS-SPECIFIC CONFIGURATION                                 │
│    Linux (dot_config, systemd) vs Windows (AppData, Scoop)  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 3. MACHINE-SPECIFIC CONFIGURATION                           │
│    Hostnames, chassis profiles, display geometries          │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 4. HARDWARE-SPECIFIC CONFIGURATION                           │
│    Intel iGPU + RTX 5050 Optimus offload, ASUS TUF WMI      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 5. PROVIDER-SPECIFIC CONFIGURATION                           │
│    Package managers (paru/scoop), Bootloader, Greeter, Audio│
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│ 6. OPTIONAL FEATURES                                         │
│    Gaming stack, development runtimes, HDR, Snapper CoW     │
└─────────────────────────────────────────────────────────────┘
```

---

## Provider Selection vs. State Reconciliation

A key design principle of this repository is distinguishing **provider selection** from **provider state reconciliation**:

```text
Machine Profile
      ↓
Provider Selected (e.g. login_mode = "getty-tty1-autologin", greeter = "none")
      ↓
Package Install   (install selected tools)
      ↓
Configuration     (deploy declarative configs via chezmoi)
      ↓
Enablement        (enable active services via run_onchange_ scripts)
      ↓
Verification      (verify expected state via scripts/verify/)
      ↓
Old Provider Cleanup (retire deactivated services or conflicting overrides)
```

### Dynamic Reconciliation via `run_onchange_`
Rather than one-time execution scripts (`run_once_`), service and package orchestration is handled by `run_onchange_reconcile-services.sh.tmpl` and `run_onchange_reconcile-packages.sh.tmpl`. These scripts compute a cryptographic hash of the machine profile's providers and features. When any provider or feature is changed:
1. Chezmoi detects the hash change.
2. The reconciler runs automatically.
3. Desired services are activated, and retired services (e.g. disabled Bluetooth, deactivated display managers) are cleanly stopped and disabled.

---

## Declarative Boundary vs. Firmware Mutation

Chezmoi manages **declarative filesystem state**; it does not manage one-time firmware or hardware NVRAM mutations:

| Category | Declarative Chezmoi State | Host Firmware / Installation Mutation |
|---|---|---|
| **Bootloader** | `/etc/default/grub`, kernel parameters, themes | `grub-install --target=x86_64-efi`, `efibootmgr` NVRAM entries |
| **Filesystem** | `chattr +C` directory flags, snapper config text | `mkfs.btrfs`, subvolume creation (`btrfs subvolume create`) |
| **User & Shell**| Dotfiles, fish configs, user units | `useradd`, initial wheel group permissions |

Firmware and partition setup are one-time provisioning steps documented in [`docs/bootstrap.md`](bootstrap.md).

---

## Layer Roles & Mechanisms

### 1. Common Layer
- **Source:** `.chezmoidata.toml` (`[defaults]`), `packages/common.txt`, `.chezmoitemplates/`
- **Scope:** Cross-platform developer identities, aliases, Git credentials, and baseline text processing tools. Decoupled from personal identities in public templates.

### 2. OS Layer
- **Source:** Managed via `.chezmoiignore` guards (`ne .chezmoi.os "windows"`, `ne .chezmoi.os "linux"`)
- **Linux:** Manages `dot_config/**`, `dot_local/**`, `.bashrc`, `.profile`.
- **Windows:** Manages `AppData/**`, `readonly_Documents/**`, `scoop/**`, `.chezmoiscripts/run_once_after_windows_apply.ps1.tmpl`.

### 3. Machine Layer
- **Source:** Defined under `[machines.<id>]` in `.chezmoidata.toml` and prompted/stored via `.chezmoi.toml.tmpl`.
- **Profiles:**
  - `asus-tuf-f16`: ASUS TUF Gaming F16 laptop.
  - `windows-workstation`: Primary Windows 11 environment.
  - `generic-linux`: Portable Arch Linux workstation fallback.

### 4. Hardware Layer
- **Source:** Composable entries under `[hardware.<id>]` and referenced by machine profiles in `.chezmoidata.toml`.
- **Properties:** CPU topology (P-cores / E-cores), iGPU / dGPU buses, primary panel connector (`eDP-1`), native resolution (`1920x1200@165Hz`), and filesystem (`btrfs` vs `ntfs`).

### 5. Provider Layer
- **Source:** `machines.<id>.providers` in `.chezmoidata.toml`.
- **Abstractions:**
  - `package_manager`: `paru`, `yay`, `pacman`, `scoop`
  - `login_mode`: `getty-tty1-autologin` (0 MB RAM headless autologin), `native`
  - `greeter`: `none` (active headless), with `fallback_greeter = "ly"` preserved in `backups/`
  - `bootloader`: `grub`, `systemd-boot`, `windows-boot-manager`
  - `audio`: `pipewire-rnnoise`, `pipewire-standard`, `wasapi`
  - `xremap`: `user-service`, `none`

### 6. Feature Layer
- **Source:** `machines.<id>.features` in `.chezmoidata.toml`.
- **Flags:** `gaming`, `development`, `asus_ctl`, `bluetooth`, `hyprland`, `snapper`, `tearing_opt`.
