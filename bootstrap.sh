#!/usr/bin/env bash
# ==============================================================================
# CachyOS + Hyprland Machine Bootstrap Script
# ==============================================================================
# Sets up prerequisites (base-devel, git, paru, chezmoi, age) and applies chezmoi.
# ==============================================================================

set -euo pipefail

echo "========================================================"
echo " Starting Machine Bootstrap for CachyOS / Arch Linux"
echo "========================================================"

# 1. Ensure required core packages are installed
echo "==> [1/4] Installing core build tools and chezmoi..."
sudo pacman -Syu --needed --noconfirm git base-devel chezmoi age

# 2. Ensure AUR helper (paru) is available
echo "==> [2/4] Checking AUR helper..."
if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
    echo "Installing paru-bin from AUR..."
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$BUILD_DIR/paru-bin"
    (cd "$BUILD_DIR/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
else
    echo "AUR helper already available: $(command -v paru || command -v yay)"
fi

# 3. Age private key reminder
KEY_PATH="$HOME/.config/chezmoi/key.txt"
echo "==> [3/4] Checking age encryption key..."
if [ -f "$KEY_PATH" ]; then
    echo "Age key found at $KEY_PATH."
    chmod 600 "$KEY_PATH"
else
    echo "--------------------------------------------------------"
    echo "WARNING: Age private key not found at $KEY_PATH"
    echo "To decrypt encrypted secrets (MCP configs, tokens),"
    echo "place your age key at: $KEY_PATH with permissions 600."
    echo "--------------------------------------------------------"
fi

# 4. Initialize / Apply chezmoi
echo "==> [4/4] Applying Chezmoi state..."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$DOTFILES_DIR/.git" ]; then
    echo "Applying from local repository: $DOTFILES_DIR"
    chezmoi apply --source "$DOTFILES_DIR"
else
    read -rp "Enter dotfiles Git repository URL: " REPO_URL
    chezmoi init --apply "$REPO_URL"
fi

echo "========================================================"
echo " Machine bootstrap and Chezmoi deployment complete!"
echo " Log out or restart Hyprland session to apply changes."
echo "========================================================"
