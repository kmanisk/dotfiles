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

## Layer Roles & Mechanisms

### 1. Common Layer
- **Source:** `.chezmoidata.toml` (`[defaults]`), `packages/common.txt`, `.chezmoitemplates/`
- **Scope:** Cross-platform developer identities, aliases, Git credentials, and baseline text processing tools.

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
- **Source:** `machines.<id>.hardware` in `.chezmoidata.toml`.
- **Properties:** CPU topology (P-cores / E-cores), iGPU / dGPU buses, primary panel connector (`eDP-1`), native resolution (`1920x1200@165Hz`), and filesystem (`btrfs` vs `ntfs`).

### 5. Provider Layer
- **Source:** `machines.<id>.providers` in `.chezmoidata.toml`.
- **Abstractions:**
  - `package_manager`: `paru`, `yay`, `pacman`, `scoop`
  - `greeter`: `ly`, `sddm`, `none`
  - `login_mode`: `getty-tty1-autologin` (0 MB RAM overhead), `native`
  - `bootloader`: `grub`, `systemd-boot`, `windows-boot-manager`
  - `audio`: `pipewire-rnnoise`, `pipewire-standard`, `wasapi`
  - `xremap`: `user-service`, `system-service`, `none`

### 6. Feature Layer
- **Source:** `machines.<id>.features` in `.chezmoidata.toml`.
- **Flags:** `gaming`, `development`, `asus_ctl`, `bluetooth`, `hyprland`, `snapper`, `tearing_opt`.

---

## Directory Organization

| Directory / File | Description | Target OS |
|---|---|---|
| `.chezmoidata.toml` | Global data definitions and machine specifications | All |
| `.chezmoi.toml.tmpl` | Host configuration template (machine identity, age) | All |
| `.chezmoiignore` | Precise deployment filtering matrix | All |
| `.chezmoitemplates/` | Reusable partial templates (`git-identity`, `file-header`) | All |
| `packages/` | Modular package manifests | All |
| `dot_config/` | XDG desktop configs (Hyprland, Waybar, Fish, Matugen) | Linux |
| `AppData/` | Roaming and Local application data | Windows |
| `readonly_Documents/` | Windows game configurations and saves | Windows |
| `scoop/` | Windows Scoop manifests and buckets | Windows |
| `backups/` | Fallback archives (Ly, GRUB, ASUS, XRemap, PAM) | Linux |
| `scripts/` | Audit, verification, and bootstrap tool runners | All |
| `docs/` | Architecture and operations documentation | All |
