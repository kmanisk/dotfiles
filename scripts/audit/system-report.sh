#!/usr/bin/env bash
# ==============================================================================
# Cross-Platform Dotfiles Audit: System Inspection & Telemetry Report
# ==============================================================================
# Generates a sanitized, comprehensive report of system hardware, kernel,
# GPU state, audio pipeline, storage, services, and greeter configurations.
# ==============================================================================

set -euo pipefail

OUT_FILE="${1:-/tmp/dotfiles-system-report-$(date +%Y%m%d-%H%M%S).txt}"

log() {
    echo -e "$@" | tee -a "$OUT_FILE"
}

log "=============================================================================="
log " SYSTEM AUDIT & ENVIRONMENT REPORT"
log " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
log "=============================================================================="

# 1. OS & Kernel
log "\n[1. OS & KERNEL INFORMATION]"
if [ -f /etc/os-release ]; then
    log "Distro: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
fi
log "Kernel: $(uname -r) ($(uname -m))"
log "Uptime: $(uptime -p 2>/dev/null || uptime)"

# 2. CPU Information
log "\n[2. CPU & SCHEDULER]"
log "Model: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')"
log "Cores: $(nproc) logical threads"
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    log "Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'N/A')"
    log "Driver:   $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver 2>/dev/null || echo 'N/A')"
fi

# 3. Memory & ZRAM
log "\n[3. MEMORY & SWAP]"
free -h | tee -a "$OUT_FILE"
if command -v zramctl >/dev/null 2>&1; then
    log "\nZRAM Status:"
    zramctl 2>/dev/null | tee -a "$OUT_FILE" || true
fi

# 4. Storage & Filesystem
log "\n[4. STORAGE & MOUNT POINTS]"
df -hT -x tmpfs -x devtmpfs | tee -a "$OUT_FILE"
if command -v btrfs >/dev/null 2>&1; then
    log "\nBtrfs Subvolumes:"
    btrfs subvolume list / 2>/dev/null | head -n 15 | tee -a "$OUT_FILE" || true
fi
if command -v snapper >/dev/null 2>&1; then
    log "\nSnapper Configs:"
    snapper list-configs 2>/dev/null | tee -a "$OUT_FILE" || true
    log "\nRecent Root Snapshots (Last 5):"
    snapper -c root list 2>/dev/null | tail -n 6 | tee -a "$OUT_FILE" || true
fi

# 5. GPU & Display
log "\n[5. GPU SUBSYSTEM & POWER MANAGEMENT]"
log "PCI Display Devices:"
lspci -nnk | grep -A 3 -E "VGA|3D" | tee -a "$OUT_FILE"
if [ -f /sys/bus/pci/devices/0000:01:00.0/power/runtime_status ]; then
    log "NVIDIA Runtime Status: $(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status)"
fi
if command -v nvidia-smi >/dev/null 2>&1; then
    log "NVIDIA Driver & SMI:"
    nvidia-smi --query-gpu=name,driver_version,power.draw,temperature.gpu --format=csv,noheader 2>/dev/null || echo "dGPU currently suspended in D3cold"
fi
if command -v supergfxctl >/dev/null 2>&1; then
    log "supergfxctl mode: $(supergfxctl -g 2>/dev/null || echo 'N/A')"
fi

# 6. Audio & DSP
log "\n[6. AUDIO SUBSYSTEM]"
if command -v wpctl >/dev/null 2>&1; then
    log "Default Audio Sinks & Sources:"
    wpctl status 2>/dev/null | grep -E "Audio|Sinks|Sources|Streams" -A 10 | head -n 25 | tee -a "$OUT_FILE" || true
fi
log "Running DSP Engines:"
pgrep -fla "dusky_audio_studio|rnnoise" || echo "No active python RNNoise DSP daemon detected"

# 7. Greeter & Login
log "\n[7. GREETER & AUTOLOGIN CONFIGURATION]"
if [ -d /etc/systemd/system/getty@tty1.service.d ]; then
    log "getty@tty1 override detected (Headless Autologin):"
    cat /etc/systemd/system/getty@tty1.service.d/*.conf 2>/dev/null | sed 's/--autologin [^ ]*/--autologin <USER>/' | tee -a "$OUT_FILE" || true
fi
if systemctl is-enabled ly.service >/dev/null 2>&1; then
    log "Ly Display Manager: enabled"
else
    log "Ly Display Manager: disabled (held in reserve as fallback)"
fi

# 8. Bootloader
log "\n[8. BOOTLOADER & EFI]"
if [ -d /sys/firmware/efi ]; then
    log "Boot Mode: UEFI"
    if command -v efibootmgr >/dev/null 2>&1; then
        efibootmgr 2>/dev/null | head -n 10 | tee -a "$OUT_FILE" || true
    fi
else
    log "Boot Mode: Legacy BIOS"
fi

# 9. Key System Services
log "\n[9. CRITICAL SYSTEMD UNITS STATUS]"
for unit in ananicy-cpp asusd supergfxd bluetooth fstrim.timer snapper-cleanup.timer; do
    STATE=$(systemctl is-active "$unit" 2>/dev/null || echo "inactive/missing")
    log "  $unit: $STATE"
done

# Redaction pass for privacy
sed -i -E 's/([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/XX:XX:XX:XX:XX:XX/g' "$OUT_FILE"
sed -i -E 's/inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/inet [REDACTED]/g' "$OUT_FILE"

log "\n=============================================================================="
log " Report saved to: $OUT_FILE"
log "=============================================================================="
