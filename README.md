# Dotfiles

Reproducible desktop environment managed with [chezmoi](https://www.chezmoi.io/).

---

## Arch Linux Setup

### What happens on a fresh machine

On any new Arch Linux machine (or any Arch-based distro), you only need to run:

```bash
# 1. Install chezmoi
sudo pacman -S --needed git chezmoi

# 2. Initialize and apply your dotfiles
chezmoi init --apply https://github.com/kmanisk/dotfiles.git

# 3. Reboot
sudo reboot
```

### Automated Configuration & Features

- **Window Manager & Desktop**: i3wm with right-hand top-row workspace switching (`Windows + u i o p [ ]`), Picom compositor with zero-latency fullscreen game unredirection, Polybar, and Alacritty (Gruvbox dark theme).
- **Key Remapping**: `xremap.service` automatically generated, registered with systemd, enabled, and started (CapsLock tap = Escape, hold = RightCtrl, navigation layers, brightness controls).
- **Automated Software Bootstrap**: Checks and installs 35+ native packages via `pacman` and AUR packages via `paru` (`asusctl-x11`, `xremap-x11-bin`, `tmog-appimage`, `brave-origin-bin`).
- **Python Virtualenv**: Sets up `~/.local/share/i3-resurrect-venv` with `i3-resurrect` and `autotiling`.
- **Zed Editor**: Automatic installation to `~/.local/zed.app/` with conflict-free keybindings.
- **ASUS TUF Hardware Tuning**: Sets battery charge limit to **60%**, keyboard RGB to **Static Red**, and power profile to **Balanced**.
- **CS2 & Gaming Pipeline**: 
  - Stretched 165Hz modelines (`1344x1008_165.00` registered via `setup-display`).
  - Direct Vulkan rendering on dedicated RTX 5050 with P-core pinning (`taskset -c 0-11`).
  - Automatic restore of competitive video settings (`cs2_video.txt`) even on fresh game reinstalls.
  - Low-latency Pipewire audio buffer (30ms) & Bluetooth SBC-XQ codec.
- **System Tuning**: Applies `/etc/sysctl.d/99-cs2-gaming.conf` (`vm.max_map_count = 1048576`, `fs.file-max = 2097152`) and enables background daemons (`asusd`, `nvidia-powerd`, `ananicy-cpp`, `bluetooth`, `NetworkManager`).

---

## Windows Setup

### Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```

### Common Commands

```powershell
# Sync dotfiles
chezmoi apply

# Update all packages (Scoop & Winget)
uall

# Check package status
pcheck
```

### Key Files (Windows)

* `AppData/Local/installer/packages.json` — Package manifests (Scoop & Winget)
* `AppData/Local/installer/setup.ps1` — Bootstrap installer
* `readonly_Documents/PowerShell/` — PowerShell profile & custom aliases
