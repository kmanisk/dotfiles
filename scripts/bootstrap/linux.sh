#!/usr/bin/env bash
# ==============================================================================
# Cross-Platform Dotfiles: Linux Workstation Bootstrap
# ==============================================================================
# Sets up base-devel, git, chezmoi, AUR helper, and initializes chezmoi state.
# ==============================================================================

set -euo pipefail

echo "=============================================================================="
echo " Starting Linux Workstation Bootstrap (CachyOS / Arch Linux)"
echo "=============================================================================="

# 1. Base tools installation
echo "==> [1/5] Ensuring core build tools and chezmoi..."
sudo pacman -Syu --needed --noconfirm git base-devel chezmoi

# 2. AUR Helper
echo "==> [2/5] Checking AUR helper..."
if ! command -v paru >/dev/null 2>&1 && ! command -v yay >/dev/null 2>&1; then
    echo "Installing paru-bin from AUR..."
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru-bin.git "$BUILD_DIR/paru-bin"
    (cd "$BUILD_DIR/paru-bin" && makepkg -si --noconfirm)
    rm -rf "$BUILD_DIR"
else
    echo "AUR helper already available: $(command -v paru || command -v yay)"
fi

# 3. Age private key
KEY_PATH="$HOME/.config/chezmoi/key.txt"
echo "==> [3/5] Checking age encryption key..."
if [ -f "$KEY_PATH" ]; then
    echo "Age key found at $KEY_PATH."
    chmod 600 "$KEY_PATH"
else
    echo "----------------------------------------------------------------------"
    echo "WARNING: Age private key not found at $KEY_PATH"
    echo "To decrypt encrypted secrets (MCP configs, API tokens),"
    echo "place your age private key at: $KEY_PATH with permissions 600."
    echo "----------------------------------------------------------------------"
fi

# 4. Chezmoi Initialization & Application
echo "==> [4/5] Initializing / Applying Chezmoi state..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [ -d "$SCRIPT_DIR/.git" ]; then
    echo "Applying from local repository: $SCRIPT_DIR"
    chezmoi apply --source "$SCRIPT_DIR"
else
    read -rp "Enter dotfiles Git repository URL: " REPO_URL
    chezmoi init --apply "$REPO_URL"
fi

# 5. Post-apply System Verification
echo "==> [5/5] Running post-apply system health verification..."
if [ -f "$SCRIPT_DIR/scripts/verify/system.sh" ]; then
    bash "$SCRIPT_DIR/scripts/verify/system.sh" || echo "Warning: Some verification checks failed."
fi

echo "=============================================================================="
echo " Linux workstation bootstrap complete!"
echo " Log out or restart your graphical session to finalize environment changes."
echo "=============================================================================="
