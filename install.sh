#!/usr/bin/env bash
set -e

echo "==> [Dotfiles Installer] Starting Arch Linux setup..."

# 1. Enable multilib in /etc/pacman.conf if disabled (required for Steam, 32-bit Vulkan/NVIDIA)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "==> Enabling [multilib] in /etc/pacman.conf..."
    sudo sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf 2>/dev/null || \
    printf "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n" | sudo tee -a /etc/pacman.conf
    sudo pacman -Sy
fi

# 2. Install base system dependencies & NVIDIA drivers
echo "==> Installing base tools, headers, and NVIDIA drivers..."
sudo pacman -S --needed --noconfirm \
    git \
    chezmoi \
    base-devel \
    linux-headers \
    nvidia-open \
    nvidia-utils \
    lib32-nvidia-utils

# 3. Initialize and apply dotfiles via chezmoi
echo "==> Applying dotfiles..."
chezmoi init --apply https://github.com/kmanisk/dotfiles.git

echo ""
echo "========================================================"
echo " Setup complete! Please reboot your machine:"
echo "   sudo reboot"
echo "========================================================"
