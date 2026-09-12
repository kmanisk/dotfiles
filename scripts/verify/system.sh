#!/usr/bin/env bash
# ==============================================================================
# Cross-Platform Dotfiles Verification: System Health Test Runner
# ==============================================================================
# Returns exit code 0 if all system prerequisites and providers pass.
# Returns non-zero (1) if any critical provider or service fails.
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
echo " RUNNING SYSTEM VERIFICATION SUITE"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Btrfs Filesystem Checks
echo -e "\n[Category: Storage & Btrfs]"
run_check "Root is Btrfs" bash -c "df -T / | awk 'NR==2 {exit (\$2 == \"btrfs\" ? 0 : 1)}'"
run_check "Home is Btrfs" bash -c "df -T \"$HOME\" | awk 'NR==2 {exit (\$2 == \"btrfs\" ? 0 : 1)}'"
run_check "Snapper root config exists" bash -c "command -v snapper >/dev/null && sudo snapper list-configs 2>/dev/null | grep -qw root"

# 2. Hybrid GPU & Power Checks
echo -e "\n[Category: Hybrid GPU (Intel + NVIDIA)]"
run_check "Intel iGPU device present" bash -c "lspci -d 8086: | grep -q 'VGA compatible controller'"
run_check "NVIDIA dGPU device present" bash -c "lspci -d 10de: | grep -q 'VGA compatible controller'"
run_check "NVIDIA driver loaded" bash -c "lsmod | grep -qw nvidia"
run_check "Optimus dynamic power control enabled" bash -c "cat /sys/bus/pci/devices/0000:01:00.0/power/control | grep -qw auto"

# 3. Audio & DSP Checks
echo -e "\n[Category: Audio & DSP Engine]"
run_check "PipeWire daemon active" pgrep -x pipewire
run_check "WirePlumber session manager active" pgrep -x wireplumber
run_check "Dusky RNNoise DSP process running" pgrep -f "dusky_audio_studio|dusky_audio_dsp"

# 4. Critical Services Checks
echo -e "\n[Category: Systemd System Services]"
run_check "ananicy-cpp service active" systemctl is-active --quiet ananicy-cpp
run_check "fstrim timer active" systemctl is-active --quiet fstrim.timer
run_check "snapper-cleanup timer active" systemctl is-active --quiet snapper-cleanup.timer
run_check "bluetooth service active" systemctl is-active --quiet bluetooth

# Hardware specific checks (ASUS TUF)
if [ -d /sys/devices/platform/asus-nb-wmi ]; then
    echo -e "\n[Category: ASUS Hardware Management]"
    run_check "asusd service active" systemctl is-active --quiet asusd
    run_check "supergfxd service active" systemctl is-active --quiet supergfxd
fi

# 5. User Environment Checks
echo -e "\n[Category: User Environment & Encryption]"
run_check "Chezmoi binary available" command -v chezmoi
run_check "Age encryption capability available" bash -c "command -v age >/dev/null 2>&1 || (command -v chezmoi >/dev/null 2>&1 && chezmoi data | grep -q '\"useBuiltin\": true')"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mALL CHECKS PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    echo "=============================================================================="
    exit 0
else
    echo -e " \033[31mVERIFICATION FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    echo "=============================================================================="
    exit 1
fi
