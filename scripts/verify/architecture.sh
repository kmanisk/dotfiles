#!/usr/bin/env bash
# ==============================================================================
# Suite 1: Architecture & Data Model Integrity
# ==============================================================================
# Verifies .chezmoidata.toml schema, canonical hardware modeling, deduplication,
# and safe generic machine fallbacks.
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
echo " [SUITE 1/7] ARCHITECTURE & DATA MODEL INTEGRITY"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Master Data File Existence & Parseability
run_check ".chezmoidata.toml exists" test -f "$SCRIPT_DIR/.chezmoidata.toml"
run_check ".chezmoidata.toml parses cleanly in chezmoi" bash -c "chezmoi execute-template '{{ .defaults.profile }}' | grep -q 'full'"

# 2. Canonical Hardware Profiles
for hw in asus-tuf-f16 custom-desktop generic-laptop; do
    run_check "Canonical hardware profile '$hw' exists in [hardware]" bash -c "chezmoi execute-template '{{ index .hardware \"$hw\" }}' | grep -q 'gpu_strategy'"
done

# 3. Hardware Profile Deduplication Check
run_check "No duplicate [machines.asus-tuf-f16.hardware] table" bash -c "! grep -E '^\\[machines\\.asus-tuf-f16\\.hardware\\]' '$SCRIPT_DIR/.chezmoidata.toml'"
run_check "No duplicate [machines.windows-workstation.hardware] table" bash -c "! grep -E '^\\[machines\\.windows-workstation\\.hardware\\]' '$SCRIPT_DIR/.chezmoidata.toml'"
run_check "No duplicate [machines.generic-linux.hardware] table" bash -c "! grep -E '^\\[machines\\.generic-linux\\.hardware\\]' '$SCRIPT_DIR/.chezmoidata.toml'"

# 4. Canonical Hardware Reference Check
for machine in asus-tuf-f16 windows-workstation generic-linux; do
    run_check "Machine '$machine' specifies valid hardware_profile" bash -c "
        hw_prof=\$(chezmoi execute-template '{{ (index .machines \"$machine\").hardware_profile }}')
        [ -n \"\$hw_prof\" ] && chezmoi execute-template \"{{ index .hardware \\\"\$hw_prof\\\" }}\" | grep -q 'gpu_strategy'
    "
done

# 5. Safe Fallback Resolution Check (Personal machine must NOT be fallback)
run_check "defaults.machines.linux is generic-linux (not asus-tuf-f16)" bash -c "chezmoi execute-template '{{ .defaults.machines.linux }}' | grep -qx 'generic-linux'"
run_check ".chezmoi.toml.tmpl defaults Linux to generic-linux" grep -q 'defaultMachine := "generic-linux"' "$SCRIPT_DIR/.chezmoi.toml.tmpl"
run_check ".chezmoiignore defaults Linux to generic-linux" grep -q 'machineKey = "generic-linux"' "$SCRIPT_DIR/.chezmoiignore"

# 6. Internal Directory Boundaries
for dir in backups docs scripts packages hardware systemd btrfs; do
    run_check "Internal directory '$dir' ignored from \$HOME in .chezmoiignore" grep -q "^$dir/\*\*" "$SCRIPT_DIR/.chezmoiignore"
done

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mARCHITECTURE SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mARCHITECTURE SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
