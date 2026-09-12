#!/usr/bin/env bash
# ==============================================================================
# Workstation Verification: Live Host Runtime Health Suite
# ==============================================================================
# Verifies active daemons, hardware drivers, audio pipeline, and power states.
# Returns exit code 0 if all live runtime components are operational.
# ==============================================================================

set -uo pipefail

FAILED_CHECKS=0
TOTAL_CHECKS=0

pass() {
    echo -e "  \033[32m✔ PASS\033[0m: $1"
}

fail() {
    echo -e "  \033[31m✖ FAIL\033[0m: $1 ($2)"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

run_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        pass "$desc"
    else
        fail "$desc" "Command returned non-zero"
    fi
}

echo "=============================================================================="
echo " [SUITE 7/7] LIVE HOST RUNTIME HEALTH VERIFICATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Storage & Btrfs
echo -e "\n[Category: Storage & Btrfs Subvolumes]"
run_check "Root filesystem is Btrfs" bash -c "df -T / | awk 'NR==2 {exit (\$2 == \"btrfs\" ? 0 : 1)}'"
run_check "Home filesystem is Btrfs" bash -c "df -T \"$HOME\" | awk 'NR==2 {exit (\$2 == \"btrfs\" ? 0 : 1)}'"
run_check "Snapper root configuration active" bash -c "command -v snapper >/dev/null && sudo snapper list-configs 2>/dev/null | grep -qw root"

# 2. Hybrid GPU & Power States
echo -e "\n[Category: Hybrid GPU (Intel + NVIDIA)]"
run_check "Intel iGPU PCI device active" bash -c "lspci -d 8086: | grep -q 'VGA compatible controller'"
run_check "NVIDIA dGPU PCI device detected" bash -c "lspci -d 10de: | grep -q 'VGA compatible controller'"
run_check "NVIDIA kernel driver loaded" bash -c "lsmod | grep -qw nvidia"
run_check "Optimus dynamic power management in auto" bash -c "cat /sys/bus/pci/devices/0000:01:00.0/power/control | grep -qw auto"

# 3. Audio Pipeline
echo -e "\n[Category: Audio Pipeline]"
run_check "PipeWire daemon active" pgrep -x pipewire
run_check "WirePlumber session manager active" pgrep -x wireplumber

# 4. Critical Systemd Units
echo -e "\n[Category: Systemd System Daemons]"
run_check "ananicy-cpp process scheduler active" systemctl is-active --quiet ananicy-cpp
run_check "fstrim SSD trim timer active" systemctl is-active --quiet fstrim.timer
run_check "snapper-cleanup maintenance timer active" systemctl is-active --quiet snapper-cleanup.timer
run_check "bluetooth service active" systemctl is-active --quiet bluetooth

# ASUS WMI (if ASUS hardware)
if [ -d /sys/devices/platform/asus-nb-wmi ]; then
    echo -e "\n[Category: ASUS Hardware Management]"
    run_check "asusd service active" systemctl is-active --quiet asusd
    run_check "supergfxd GPU switching service active" systemctl is-active --quiet supergfxd
fi

# 5. Core Utilities
echo -e "\n[Category: Environment Tooling]"
run_check "Chezmoi binary available" command -v chezmoi
run_check "Age encryption capability available" bash -c "command -v age >/dev/null 2>&1 || (command -v chezmoi >/dev/null 2>&1 && chezmoi data | grep -q '\"useBuiltin\": true')"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mHOST HEALTH VERIFICATION: ALL CHECKS PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    echo "=============================================================================="
    exit 0
else
    echo -e " \033[31mHOST HEALTH VERIFICATION FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    echo "=============================================================================="
    exit 1
fi
