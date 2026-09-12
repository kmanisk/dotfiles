# Provider Abstraction Matrix & Reconciliation Contracts

This repository abstracts system components behind provider interfaces, allowing the same machine definition logic to configure different backend tools and dynamically reconcile them.

---

## Provider Matrix

| Subsystem | Supported Providers | Active Machine (`asus-tuf-f16`) | Notes |
|---|---|---|---|
| **Package Manager** | `paru`, `yay`, `pacman`, `scoop` | `paru` | Modeled as safe bash command arrays; checks binary executable |
| **Login Mode** | `getty-tty1-autologin`, `native` | `getty-tty1-autologin` | Zero-RAM headless autologin on TTY1 -> `startx` (i3/X11) |
| **Greeter / Display Mgr** | `none`, `ly`, `sddm`, `windows-logon` | `none` (active) | `fallback_greeter = "ly"` preserved in `backups/linux/greeters/ly/` |
| **Bootloader** | `grub`, `systemd-boot`, `windows-boot-manager` | `grub` | Declarative `/etc/default/grub` only; NVRAM mutations isolated |
| **Key Remapping** | `user-service`, `none` | `user-service` | Managed by `xremap-x11-bin` via user systemd service |
| **GPU Strategy** | `hybrid-optimus-d3cold`, `direct`, `intel-only` | `hybrid-optimus-d3cold` | Intel iGPU desktop session + NVIDIA RTX 5050 D3cold offload |
| **Audio Engine** | `pipewire-standard`, `wasapi` | `pipewire-standard` | Stock PipeWire + WirePlumber, no DSP daemon |

---

## Provider Reconciliation Contracts

Providers in this repository are managed by declarative reconcilers (`run_onchange_linux-10-reconcile-login.sh.tmpl` and `run_onchange_linux-20-reconcile-services.sh.tmpl`) and follow a strict **bidirectional reconciliation contract**:

### 1. Greeter & Autologin Contract
- **Active State (`login_mode = "getty-tty1-autologin"`, `greeter = "none"`):**
  - Configures `/etc/systemd/system/getty@tty1.service.d/override.conf` for passwordless TTY1 autologin.
  - Automatically ensures `ly.service`, `sddm.service`, and `gdm.service` are stopped and disabled to prevent TTY1 contention.
- **Standby State (`fallback_greeter = "ly"`):**
  - Full Ly configuration, PAM definition, and unit file are archived in `backups/linux/greeters/ly/`.
  - Switching to `greeter = "ly"` automatically removes the getty override and enables `ly.service`.

### 2. Browser Keyring & Password Store Isolation
- **The Challenge:** Under headless passwordless autologin, PAM does not receive a password, leaving the GNOME Keyring (`login.keyring`) locked (`Locked = true`). Standard Chromium/Brave browsers attempt to query Secret Service, causing authentication prompts or loss of saved sessions/cookies across reboots.
- **The Solution:** In `dot_config/brave-flags.conf.tmpl` and `dot_config/brave-origin-flags.conf.tmpl`, the browser secret store provider (`browser_secret_store = "basic"`) is configured via `--password-store={{ $secretStore }}`. This directs the browser to use its local encryption store, decoupling session persistence from locked PAM keyrings.
- **Verification:** Verified by `scripts/verify/providers.sh` and `scripts/verify/security.sh`.

### 3. Package Manager Provider Contract
- Safe array invocation: Package commands are declared as bash arrays (`PKG_INSTALL_CMD=(paru -S --needed --noconfirm)`), avoiding fragile shell word splitting.
- Execution checks test the actual executable binary name (`command -v paru`), safely supporting multi-word commands like `sudo pacman`.
- Snapshot hook: Before batch installation, Snapper pre-update snapshots are triggered if root Btrfs is present.

### 4. Bootloader Configuration vs. Firmware Boundary
- **What Chezmoi Manages:** Declarative configuration files (`/etc/default/grub`, kernel parameters, theme settings).
- **What Chezmoi Does Not Manage:** Firmware NVRAM modifications (`efibootmgr`, `grub-install`). These are strictly one-time installation actions executed during initial OS bootstrap.
