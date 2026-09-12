# Cross-Platform Workstation Architecture

This repository defines a modular, multi-tier workstation architecture managed entirely through [chezmoi](https://www.chezmoi.io/). It provides a single source of truth for both Linux (CachyOS / Arch / i3wm+X11) and Windows 11 workstations without fragmentation or platform dilution.

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
Rather than one-time execution scripts (`run_once_`), service and package orchestration is cleanly segregated into three specialized, ordered reconcilers:
- `run_onchange_linux-00-reconcile-packages.sh.tmpl`: Evaluates package manifest hashes, performs Snapper pre-update snapshots, and provisions packages using the declared package manager (`paru`, `yay`, or `pacman`).
- `run_onchange_linux-10-reconcile-login.sh.tmpl`: Evaluates login and greeter provider hashes, idempotent systemd autologin overrides, and clean retirement of display managers (Ly, SDDM, GDM).
- `run_onchange_linux-20-reconcile-services.sh.tmpl`: Evaluates system and user service hashes, managing bi-directional service lifecycle (enabling desired units, cleanly disabling and retiring deactivated units).

When any provider, feature, or package manifest is modified:
1. Chezmoi computes a new cryptographic hash embedded in the reconciler headers.
2. The relevant reconciler script runs automatically.
3. Desired state is activated, and retired state (e.g. disabled Bluetooth, retired ASUS daemons, conflicting display managers) is cleaned up.

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
  - `audio`: `pipewire-standard`, `wasapi`
  - `xremap`: `user-service`, `none`

### 6. Feature Layer
- **Source:** `machines.<id>.features` in `.chezmoidata.toml`.
- **Flags:** `gaming`, `development`, `asus_ctl`, `bluetooth`, `i3`, `snapper`, `tearing_opt`.
