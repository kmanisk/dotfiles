#!/usr/bin/env bash
# ==============================================================================
# Suite 4: Package Closure & Manifest Validation
# ==============================================================================
# Audits package lists, detects duplicate entries, verifies manifest closure,
# validates AUR vs official boundaries, and confirms audit snapshot isolation.
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
echo " [SUITE 4/7] PACKAGE CLOSURE & MANIFEST VALIDATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Manifest Files Existence & Non-Emptiness
echo -e "\n[Category: Package File Integrity]"
MANIFESTS=(common linux-core hyprland gaming nvidia asus audio development aur-explicit)
for m in "${MANIFESTS[@]}"; do
    run_check "Manifest packages/$m.txt exists and is non-empty" test -s "$SCRIPT_DIR/packages/$m.txt"
done

# 2. Duplicate Detection within Individual Manifests
echo -e "\n[Category: Duplicate Detection within Package Sets]"
for m in "${MANIFESTS[@]}"; do
    run_check "No duplicate packages in packages/$m.txt" bash -c "
        dups=\$(grep -vhE '^\s*#|^\s*$' '$SCRIPT_DIR/packages/$m.txt' | sort | uniq -d)
        [ -z \"\$dups\" ]
    "
done

# 3. Reference Snapshot Isolation Check
echo -e "\n[Category: Audit Snapshot Isolation]"
run_check "pacman-explicit-official.txt is excluded from active reconciliation" bash -c "
    ! grep -q 'pacman-explicit-official.txt' '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl'
"
run_check "cachyos-specific.txt is excluded from active reconciliation" bash -c "
    ! grep -q 'cachyos-specific.txt' '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl'
"

# 4. Profile Package Closure & Dependency Logic
echo -e "\n[Category: Profile Package Closure]"
run_check "asus-tuf-f16 resolves complete gaming + nvidia closure" bash -c "
    out=\$(chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'packages/gaming.txt' && echo \"\$out\" | grep -q 'packages/nvidia.txt'
"

run_check "AUR closure failure triggered when pacman provider selected" bash -c "
    tmp_cfg=\$(mktemp /tmp/chezmoi-test-pkg-XXXXXX.toml)
    echo '[data]
machine = \"generic-linux\"' > \"\$tmp_cfg\"
    out=\$(chezmoi execute-template --config \"\$tmp_cfg\" < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    rm -f \"\$tmp_cfg\"
    echo \"\$out\" | grep -q 'FAILING CLEARLY: Install an AUR helper'
"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mPACKAGE CLOSURE SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mPACKAGE CLOSURE SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
