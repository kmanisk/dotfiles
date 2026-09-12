#!/usr/bin/env bash
# ==============================================================================
# Workstation Verification: Declarative Architecture & Reproducibility Suite
# ==============================================================================
# Verifies data model closure, cross-machine template rendering, package sets,
# .chezmoiignore boundaries, browser keyring isolation, and secret scanning.
# Returns exit code 0 if all declarative reproducibility assertions pass.
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
echo " [SUITE 2] DECLARATIVE ARCHITECTURE & REPRODUCIBILITY VERIFICATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Data Model & Fleet Definitions
echo -e "\n[Category: Architecture Data Model (.chezmoidata.toml)]"
run_check "Master data file .chezmoidata.toml exists" test -f "$SCRIPT_DIR/.chezmoidata.toml"
run_check "Machine profile asus-tuf-f16 defined" bash -c "chezmoi execute-template '{{ index .machines \"asus-tuf-f16\" }}' | grep -q 'cachyos'"
run_check "Machine profile windows-workstation defined" bash -c "chezmoi execute-template '{{ index .machines \"windows-workstation\" }}' | grep -q 'windows'"
run_check "Machine profile generic-linux defined" bash -c "chezmoi execute-template '{{ index .machines \"generic-linux\" }}' | grep -q 'arch'"
run_check "Composable hardware profile asus-tuf-f16 defined" bash -c "chezmoi execute-template '{{ index .hardware \"asus-tuf-f16\" }}' | grep -q 'GB207M'"

# 2. Template Rendering Across Machine Profiles
echo -e "\n[Category: Cross-Machine Template Compilation]"
run_check "Render package reconciler for asus-tuf-f16" bash -c "chezmoi execute-template < '$SCRIPT_DIR/run_onchange_reconcile-packages.sh.tmpl' | grep -q 'Target Machine: asus-tuf-f16'"
run_check "Render service reconciler for asus-tuf-f16" bash -c "chezmoi execute-template < '$SCRIPT_DIR/run_onchange_reconcile-services.sh.tmpl' | grep -q 'Target Machine: asus-tuf-f16'"
run_check "Render gitconfig with reusable template" bash -c "chezmoi execute-template < '$SCRIPT_DIR/dot_gitconfig.tmpl' | grep -q '\[user\]'"

# 3. Declarative Package Closure
echo -e "\n[Category: Declarative Package Manifests]"
for pkg_set in common linux-core hyprland gaming nvidia asus audio development; do
    run_check "Package set packages/$pkg_set.txt valid" bash -c "test -s '$SCRIPT_DIR/packages/$pkg_set.txt' && grep -vE '^\s*#|^\s*$' '$SCRIPT_DIR/packages/$pkg_set.txt' | head -n 1 | grep -qv ' '"
done
run_check "Audit snapshot pacman-explicit-official.txt preserved" test -f "$SCRIPT_DIR/packages/pacman-explicit-official.txt"

# 4. Target Directory Isolation (.chezmoiignore)
echo -e "\n[Category: Target Boundary & Directory Isolation]"
for dir in backups docs scripts packages hardware systemd btrfs; do
    run_check "Internal directory $dir ignored from \$HOME deployment" grep -q "^$dir/\*\*" "$SCRIPT_DIR/.chezmoiignore"
done

# 5. Browser Keyring & Autologin Protection
echo -e "\n[Category: Headless Autologin & Keyring Security]"
run_check "brave-flags.conf contains --password-store=basic" grep -q -- "--password-store=basic" "$SCRIPT_DIR/dot_config/brave-flags.conf"
run_check "brave-origin-flags.conf contains --password-store=basic" grep -q -- "--password-store=basic" "$SCRIPT_DIR/dot_config/brave-origin-flags.conf"
run_check "Headless TTY1 autologin override preserved in backups" test -f "$SCRIPT_DIR/backups/linux/greeters/ly/getty-tty1-autologin-override.conf"
run_check "Ly cold-standby backup preserved in backups" test -f "$SCRIPT_DIR/backups/linux/greeters/ly/config.ini"

# 6. Script Syntax Integrity
echo -e "\n[Category: Shell Script Syntax Validation]"
run_check "Rendered package reconciler passes bash -n" bash -c "chezmoi execute-template < '$SCRIPT_DIR/run_onchange_reconcile-packages.sh.tmpl' | bash -n"
run_check "Rendered service reconciler passes bash -n" bash -c "chezmoi execute-template < '$SCRIPT_DIR/run_onchange_reconcile-services.sh.tmpl' | bash -n"
run_check "Bootstrap linux.sh passes bash -n" bash -n "$SCRIPT_DIR/scripts/bootstrap/linux.sh"
run_check "Audit system-report.sh passes bash -n" bash -n "$SCRIPT_DIR/scripts/audit/system-report.sh"
run_check "Health suite health.sh passes bash -n" bash -n "$SCRIPT_DIR/scripts/verify/health.sh"

# 7. Secret Scan
echo -e "\n[Category: Repository Security & Secret Scanning]"
run_check "Zero unencrypted private keys in git tree" bash -c "! git -C '$SCRIPT_DIR' grep -E 'BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY'"
run_check "Zero plaintext tokens in git tree" bash -c "! git -C '$SCRIPT_DIR' grep -iE 'ghp_[a-zA-Z0-9]{20,}'"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mREPRODUCIBILITY SUITE: ALL CHECKS PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    echo "=============================================================================="
    exit 0
else
    echo -e " \033[31mREPRODUCIBILITY SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    echo "=============================================================================="
    exit 1
fi
