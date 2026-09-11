# Dotfiles — CachyOS + Hyprland Gaming & Workstation Setup

Fully reproducible, cross-platform machine configuration managed with [chezmoi](https://www.chezmoi.io/) and encrypted with [age](https://github.com/FiloSottile/age).

---

## System Specification

- **Target OS:** CachyOS rolling (BORE/EEVDF scheduler, `x86-64-v3` optimized)
- **Compositor:** Hyprland (Wayland) @ 1920x1200 165Hz
- **Hardware:** Intel Core i5-13450HX + NVIDIA GeForce RTX 5050 Mobile (Optimus hybrid)
- **Storage:** Btrfs on NVMe (`@`, `@home`, `@snapshots`) with Snapper integration
- **Shell & Terminal:** `fish` (with pure prompt) + `alacritty` / `kitty` + `starship` + `delta`
- **AI Agent Toolchain:** Antigravity CLI (`agy`), dynamic MCP server wrappers, scoped project rules

---

## Provisioning a Fresh Machine (Arch / CachyOS)

### 1. Pre-requisite: Age Private Key

Encrypted secrets (such as dynamic MCP credentials and private configurations) require your Age identity key. Before applying dotfiles, securely copy your private key:

```bash
mkdir -p ~/.config/chezmoi
# Copy key.txt onto the machine out-of-band:
chmod 600 ~/.config/chezmoi/key.txt
```

> [!IMPORTANT]
> The private key `~/.config/chezmoi/key.txt` is strictly excluded from git tracking (`.gitignore` and `.chezmoiignore`). Never commit or push this file.

### 2. Run the Bootstrap Script

Clone the repository and inspect `bootstrap.sh` before running:

```bash
git clone https://github.com/kmanisk/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
./bootstrap.sh
```

Or run directly via remote script (pin to a commit or tag for production predictability):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kmanisk/dotfiles/master/bootstrap.sh)"
```

### What `bootstrap.sh` Executes

1. **System Core Prerequisites:** Installs `git`, `base-devel`, `chezmoi`, and `age` via `sudo pacman -Syu --needed`.
2. **AUR Helper:** Installs `paru-bin` from AUR if neither `paru` nor `yay` is present.
3. **Key Validation:** Verifies existence and `0600` permissions on `~/.config/chezmoi/key.txt`.
4. **Chezmoi Apply:** Triggers `chezmoi apply`, which sequentially executes:
   - `run_onchange_install-packages.sh.tmpl`: Takes a pre-update Snapper snapshot and installs all 259 explicitly tracked packages (69 official Arch, 182 CachyOS repo, 8 AUR) via `paru -S --needed --noconfirm`.
   - `run_once_setup-btrfs-nodatacow.sh.tmpl`: Configures `chattr +C` (No-CoW) on empty Steam and Wine library directories before data is populated.
   - `run_once_enable-services.sh.tmpl`: Enables critical systemd units (`ananicy-cpp`, `asusd`, `supergfxd`, `bluetooth`, `fstrim.timer`, `snapper-cleanup.timer`, `xremap`, `hypridle`, `mako`) and configures the ASUS battery charge limit to 60%.

---

## Daily Management

| Command | Action |
| :--- | :--- |
| `chezmoi status` | View unmanaged or pending modifications |
| `chezmoi diff` | Show unified diff between local system and source state |
| `chezmoi apply` | Deploy latest configuration changes to host |
| `chezmoi update` | Pull latest commits from Git and apply changes |
| `chezmoi add <path>` | Add or update a file in the dotfiles repository |
| `chezmoi add --encrypt <path>` | Add a sensitive file encrypted with Age |
| `chezmoi cd` | Open a shell in the chezmoi source directory (`~/.local/share/chezmoi`) |

---

## Architecture & Subsystems

### 1. Hybrid GPU Strategy (Optimus)
- **Desktop Session:** Runs strictly on the Intel UHD integrated GPU (`LIBVA_DRIVER_NAME=iHD` in `gpu.lua`) to preserve idle thermals and battery runtime.
- **On-Demand Offloading:** Discrete RTX 5050 Mobile stays in `D3cold` suspended state until explicitly engaged:
  ```bash
  gamemoderun prime-run %command%
  ```
- **Supergfxd:** Configured in `Hybrid` mode in `hardware/supergfxd.conf`.

### 2. Btrfs Safety & No-CoW Gaming
- Copy-on-Write causes severe fragmentation on large game virtual disk images and shader caches.
- **Rule:** `chattr +C` only affects files written *after* the attribute is set. Target directories (`~/.local/share/Steam/steamapps/common`, `~/.wine`, `~/.local/share/bottles`) are pre-created with `+C` on first apply.

### 3. Local Toolchain & MCP Integrations
Stored in `~/.local/bin/` and tracked in Chezmoi:
- **`gpu-tuning-mcp`**: Query RTX 5050 power metrics, runtime status, and CPU scaling governor.
- **`chezmoi-mcp`**: Chezmoi dotfile querying and status bridge.
- **`matugen-mcp`**: Material You color extraction from wallpapers for desktop ricing.
- **`systemd-mcp`**: Service management and journal crash dump inspection.
- **`desktop-mcp`**: Wayland notifications and PipeWire/WirePlumber volume routing.
- **`github-mcp-wrapper`**: Dynamic on-demand token decryption via Chezmoi; zero plaintext secrets on disk.

### 4. Reference-Only State (Audit & Non-Auto-Applied)
The repository contains machine snapshots for auditing that are intentionally **ignored** from being copied to `$HOME` or root:
- [`packages/`](file:///home/manisk/.local/share/chezmoi/packages/): Complete package lists and system ecosystem inventory.
- [`hardware/`](file:///home/manisk/.local/share/chezmoi/hardware/): Kernel boot command line, modprobe drop-ins, and ASUS fan/armoury RON configurations (`asusd.ron`, `aura_tuf.ron`, `fan_curves.ron`).
- [`systemd/`](file:///home/manisk/.local/share/chezmoi/systemd/): List of 32 enabled system & user unit files.
- [`btrfs/`](file:///home/manisk/.local/share/chezmoi/btrfs/): Snapper root/home configurations and subvolume map.
- [`sudoers-reference.txt`](file:///home/manisk/.local/share/chezmoi/sudoers-reference.txt): Captures `/etc/sudoers.d/*`. **Notice:** Contains `/etc/sudoers.d/agy-nopasswd` (`ALL=(ALL) NOPASSWD: ALL`), which is strictly reference-only and must be reviewed manually before deployment on any new host.

---

## Windows Setup (Cross-Platform)

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```

Sync anytime:
```powershell
chezmoi apply
```
