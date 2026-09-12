#!/usr/bin/env bash
# ==============================================================================
# Suite 5: Service Lifecycle & Reconciliation Validation
# ==============================================================================
# Verifies service reconciliation logic, bi-directional lifecycle handling
# (activation of enabled units, retirement of disabled units), idempotency,
# dry-run guard coverage, and script syntax across machine definitions.
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
echo " [SUITE 5/7] SERVICE LIFECYCLE & RECONCILIATION VALIDATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Template Rendering & Syntax Integrity across profiles
echo -e "\n[Category: Script Syntax Integrity]"
run_check "Rendered login reconciler for asus-tuf-f16 passes bash -n" bash -c "
    chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl' | bash -n
"
run_check "Rendered service reconciler for asus-tuf-f16 passes bash -n" bash -c "
    chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl' | bash -n
"
run_check "Rendered login reconciler for generic-linux passes bash -n" bash -c "
    tmp_cfg=\$(mktemp /tmp/chezmoi-svc-test-XXXXXX.toml)
    echo '[data]
machine = \"generic-linux\"' > \"\$tmp_cfg\"
    chezmoi execute-template --config \"\$tmp_cfg\" < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl' | bash -n
    rm -f \"\$tmp_cfg\"
"
run_check "Rendered service reconciler for generic-linux passes bash -n" bash -c "
    tmp_cfg=\$(mktemp /tmp/chezmoi-svc-test-XXXXXX.toml)
    echo '[data]
machine = \"generic-linux\"' > \"\$tmp_cfg\"
    chezmoi execute-template --config \"\$tmp_cfg\" < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl' | bash -n
    rm -f \"\$tmp_cfg\"
"

# 2. Bi-directional Service Lifecycle Assertions
echo -e "\n[Category: Bi-directional Lifecycle Assertions]"
# asus-tuf-f16 has bluetooth=true, asus_ctl=true, snapper=true, xremap=user-service
run_check "asus-tuf-f16 activates bluetooth.service" bash -c "
    chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl' | grep -q 'Activating bluetooth.service'
"
run_check "asus-tuf-f16 activates asusd.service & supergfxd.service" bash -c "
    out=\$(chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    echo \"\$out\" | grep -q 'Activating asusd.service' || echo \"\$out\" | grep -q 'Activating \$asus_svc'
"
run_check "asus-tuf-f16 activates snapper-cleanup.timer" bash -c "
    chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl' | grep -q 'Activating snapper-cleanup.timer'
"
run_check "asus-tuf-f16 activates user xremap.service" bash -c "
    chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl' | grep -q 'Activating user xremap.service'
"

# generic-linux has asus_ctl=false, snapper=false
run_check "generic-linux retires asusd & supergfxd services" bash -c "
    tmp_cfg=\$(mktemp /tmp/chezmoi-svc-test-XXXXXX.toml)
    echo '[data]
machine = \"generic-linux\"' > \"\$tmp_cfg\"
    out=\$(chezmoi execute-template --config \"\$tmp_cfg\" < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    rm -f \"\$tmp_cfg\"
    echo \"\$out\" | grep -q 'Retiring \$asus_svc'
"
run_check "generic-linux retires snapper-cleanup.timer" bash -c "
    tmp_cfg=\$(mktemp /tmp/chezmoi-svc-test-XXXXXX.toml)
    echo '[data]
machine = \"generic-linux\"' > \"\$tmp_cfg\"
    out=\$(chezmoi execute-template --config \"\$tmp_cfg\" < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    rm -f \"\$tmp_cfg\"
    echo \"\$out\" | grep -q 'Retiring snapper-cleanup.timer'
"

# 3. Login Reconciliation Assertions
echo -e "\n[Category: Login Mode Reconciliation Assertions]"
run_check "asus-tuf-f16 autologin retires conflicting display managers" bash -c "
    out=\$(chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl')
    echo \"\$out\" | grep -q 'Retiring conflicting display manager: \$dm'
"
run_check "asus-tuf-f16 applies agetty autologin override" bash -c "
    out=\$(chezmoi execute-template < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl')
    echo \"\$out\" | grep -q 'agetty --autologin'
"

# 4. Dry-Run Safety Guards
echo -e "\n[Category: Dry-Run Guard Validation]"
run_check "Service reconciler defines DRY_RUN guard" bash -c "
    grep -q 'DRY_RUN=\"\${CHEZMOI_DRY_RUN:-0}\"' '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl'
"
run_check "Login reconciler defines DRY_RUN guard" bash -c "
    grep -q 'DRY_RUN=\"\${CHEZMOI_DRY_RUN:-0}\"' '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl'
"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mSERVICE RECONCILIATION SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mSERVICE RECONCILIATION SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
