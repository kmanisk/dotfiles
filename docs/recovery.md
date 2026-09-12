# Disaster Recovery & Fallback Guide

This document details emergency recovery procedures, including restoring the Ly display manager from repository backups, rolling back Btrfs snapshots, and recovering boot/PAM configurations.

---

## 1. Restoring Ly Display Manager Fallback

The active system uses a zero-RAM headless systemd getty autologin on TTY1 with `exec start-hyprland` in `~/.config/fish/config.fish`.

If you ever wish to revert to the Ly display manager (or if TTY autologin fails):

### Exact Restoration Commands
```bash
# 1. Disable TTY1 autologin override
sudo rm -f /etc/systemd/system/getty@tty1.service.d/override.conf
sudo systemctl daemon-reload

# 2. Restore Ly configuration and service unit from repository backups
BACKUP_DIR="$HOME/.local/share/chezmoi/backups/linux/greeters/ly"
sudo cp "$BACKUP_DIR/config.ini" /etc/ly/config.ini
sudo cp "$BACKUP_DIR/ly@.service" /usr/lib/systemd/system/ly@.service

# 3. Restore Ly autologin PAM file if desired
sudo cp "$BACKUP_DIR/ly-autologin" /etc/pam.d/ly-autologin 2>/dev/null || true

# 4. Enable and start Ly service
sudo systemctl enable ly.service
sudo systemctl restart ly.service
```

---

## 2. Btrfs Snapshot Rollback (Snapper)

If a system update or bad configuration makes the system unstable, use Snapper to rollback to a known good baseline.

### Finding Snapshots
```bash
sudo snapper -c root list
```

### Safe Snapshot Rollback
```bash
# Replace <SNAPSHOT_NUM> with the target snapshot ID (e.g. 282)
sudo snapper -c root rollback <SNAPSHOT_NUM>
sudo reboot
```

### Inspecting Snapshot Space & Cleanup
```bash
# Inspect exclusive disk space consumed by snapshots:
sudo btrfs filesystem du -s /.snapshots/*/snapshot

# Delete transient or stale snapshots:
sudo snapper -c root delete <SNAPSHOT_NUM>
```

---

## 3. Restoring ASUS Hardware & Fan Configurations

If ASUS WMI or GPU switching configs become corrupted:
```bash
BACKUP_DIR="$HOME/.local/share/chezmoi/backups/linux/asus"

sudo cp "$BACKUP_DIR/supergfxd.conf" /etc/supergfxd.conf
sudo cp "$BACKUP_DIR/asusd.ron" /etc/asusd/asusd.ron 2>/dev/null || true
sudo cp "$BACKUP_DIR/fan_curves.ron" /etc/asusd/fan_curves.ron 2>/dev/null || true

sudo systemctl restart asusd supergfxd
```

---

## 4. Restoring GRUB & PAM

If GRUB or PAM configuration needs to be recovered:
```bash
# Restoring GRUB defaults
sudo cp "$HOME/.local/share/chezmoi/backups/linux/bootloaders/grub/grub" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Restoring PAM
BACKUP_PAM="$HOME/.local/share/chezmoi/backups/linux/pam"
sudo cp "$BACKUP_PAM/login" /etc/pam.d/login
sudo cp "$BACKUP_PAM/system-login" /etc/pam.d/system-login
sudo cp "$BACKUP_PAM/system-auth" /etc/pam.d/system-auth
sudo cp "$BACKUP_PAM/system-local-login" /etc/pam.d/system-local-login
```
