# Dotfiles

## Arch Linux

```bash
curl -fsSL https://raw.githubusercontent.com/kmanisk/dotfiles/master/install.sh | bash
```

Or manually:

```bash
sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf && sudo pacman -Sy
sudo pacman -S --needed git chezmoi base-devel linux-headers nvidia-open nvidia-utils lib32-nvidia-utils
chezmoi init --apply https://github.com/kmanisk/dotfiles.git
sudo reboot
```

## Windows

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://github.com/kmanisk/dotfiles/raw/master/AppData/Local/installer/setup.ps1 -OutFile $env:TEMP\setup.ps1; & $env:TEMP\setup.ps1"
```
