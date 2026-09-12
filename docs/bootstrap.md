# Workstation Bootstrap Guide

Step-by-step procedures for provisioning new machines from scratch into this repository.

---

## 1. Linux Provisioning (CachyOS / Arch Linux)

### Prerequisites
A minimal Arch Linux or CachyOS installation with network connectivity and a sudo-capable user.

### Quick Bootstrap Command
```bash
# 1. Clone or download bootstrap script
curl -fsSL https://raw.githubusercontent.com/kmanisk/dotfiles/master/scripts/bootstrap/linux.sh -o bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

### Manual Step-by-Step Procedure
1. **Install Core Tooling:**
   ```bash
   sudo pacman -Syu --needed git base-devel chezmoi
   ```
2. **Install AUR Helper (if missing):**
   ```bash
   git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
   (cd /tmp/paru-bin && makepkg -si --noconfirm)
   rm -rf /tmp/paru-bin
   ```
3. **Provision Age Private Key (for secrets):**
   ```bash
   mkdir -p ~/.config/chezmoi
   chmod 700 ~/.config/chezmoi
   # Copy your age identity key:
   cp /path/to/key.txt ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```
4. **Initialize Chezmoi:**
   ```bash
   chezmoi init --apply https://github.com/kmanisk/dotfiles.git
   ```
   *When prompted for `machine`, enter `asus-tuf-f16` (or `generic-linux` on other hardware).*
5. **Verify System Integrity:**
   ```bash
   ~/.local/share/chezmoi/scripts/verify/system.sh
   ```

---

## 2. Windows 11 Provisioning

### Quick Bootstrap Command (Elevated / PowerShell)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iwr -useb https://raw.githubusercontent.com/kmanisk/dotfiles/master/scripts/bootstrap/windows.ps1 | iex
```

### Manual Step-by-Step Procedure
1. **Install Scoop Package Manager:**
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   irm get.scoop.sh | iex
   ```
2. **Install Prerequisites:**
   ```powershell
   scoop install git chezmoi age
   ```
3. **Provision Age Key:**
   ```powershell
   New-Item -ItemType Directory -Path "$env:USERPROFILE\.config\chezmoi" -Force
   # Place your private key at:
   # $env:USERPROFILE\.config\chezmoi\key.txt
   ```
4. **Initialize & Apply:**
   ```powershell
   chezmoi init --apply https://github.com/kmanisk/dotfiles.git
   ```
   *When prompted, choose `windows-workstation`.*
