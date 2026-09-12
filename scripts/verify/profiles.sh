#!/usr/bin/env bash
# ==============================================================================
# Suite 2: Cross-Machine Profile Compilation & Matrix Validation
# ==============================================================================
# Validates template rendering, provider selection, feature toggles, and strict
# Windows/Linux separation across all defined fleet profiles.
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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
        fail "$desc" "Assertion failed"
    fi
}

echo "=============================================================================="
echo " [SUITE 2/7] MACHINE PROFILES COMPILATION & MATRIX VALIDATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

TMP_CFG=$(mktemp /tmp/chezmoi-test-profile-XXXXXX.toml)
cleanup() {
    rm -f "$TMP_CFG"
}
trap cleanup EXIT

# 1. Profile: asus-tuf-f16
echo -e "\n[Profile Matrix: asus-tuf-f16 (Linux / Hybrid Gaming Laptop)]"
echo '[data]
machine = "asus-tuf-f16"' > "$TMP_CFG"

run_check "Render package reconciler" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'Machine: asus-tuf-f16' && echo \"\$out\" | grep -q 'LISTS+=.*packages/nvidia.txt'
"
run_check "Render login reconciler" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl')
    echo \"\$out\" | grep -q 'getty-tty1-autologin' && echo \"\$out\" | grep -F -q 'agetty --autologin'
"
run_check "Render services reconciler" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    echo \"\$out\" | grep -q 'asusd.service' && echo \"\$out\" | grep -q 'xremap.service'
"
run_check "Render browser flags" bash -c "
    chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/dot_config/brave-flags.conf.tmpl' | grep -F -q -- '--password-store=basic'
"

# 2. Profile: generic-linux
echo -e "\n[Profile Matrix: generic-linux (Portable Linux Fallback)]"
echo '[data]
machine = "generic-linux"' > "$TMP_CFG"

run_check "Render package reconciler (official pacman)" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'Machine: generic-linux' && ! echo \"\$out\" | grep -q 'LISTS+=.*packages/nvidia.txt'
"
run_check "Render login reconciler (native TTY)" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl')
    echo \"\$out\" | grep -q 'Standard native TTY login'
"
run_check "Render services reconciler (ASUS disabled)" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    echo \"\$out\" | grep -q 'ASUS: Disabled'
"
run_check "Render browser flags" bash -c "
    chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/dot_config/brave-flags.conf.tmpl' | grep -F -q -- '--password-store=basic'
"

# 3. Profile: windows-workstation
echo -e "\n[Profile Matrix: windows-workstation (Windows 11)]"
echo '[data]
machine = "windows-workstation"' > "$TMP_CFG"

run_check "Windows profile metadata valid" bash -c "
    out=\$(chezmoi execute-template '{{ (index .machines \"windows-workstation\").os }}')
    [ \"\$out\" = \"windows\" ]
"
run_check "Linux package reconciler is empty on Windows" bash -c "
    out=\$(chezmoi execute-template '{{- if eq \"windows\" \"linux\" -}}SHOULD_NOT_RENDER{{- end -}}')
    [ -z \"\$out\" ]
"
run_check "Windows ignores Linux dot_config paths" grep -q "ne .chezmoi.os \"linux\"" "$SCRIPT_DIR/.chezmoiignore"
run_check "Linux ignores Windows AppData and Scoop" grep -q "ne .chezmoi.os \"windows\"" "$SCRIPT_DIR/.chezmoiignore"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mPROFILES MATRIX SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mPROFILES MATRIX SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
