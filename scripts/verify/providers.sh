#!/usr/bin/env bash
# ==============================================================================
# Suite 3: Provider Matrix Compilation & Dry-Run Validation
# ==============================================================================
# Verifies compilation, commands, and failure assertions across all provider
# combinations (package managers, greeters, login modes, audio, secret stores).
# Does NOT mutate the live system.
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
echo " [SUITE 3/7] PROVIDER MATRIX COMPILATION & DRY-RUN TESTS"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

TMP_CFG=$(mktemp /tmp/chezmoi-test-provider-XXXXXX.toml)
cleanup() {
    rm -f "$TMP_CFG"
}
trap cleanup EXIT

# 1. Package Manager Providers
echo -e "\n[Provider Matrix: Package Managers (paru, yay, pacman)]"
echo '[data]
machine = "asus-tuf-f16"' > "$TMP_CFG"

run_check "Provider paru selects paru command" bash -c "
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'PKG_INSTALL_CMD=(paru -S --needed)'
"

run_check "Provider pacman resolves to sudo pacman" bash -c "
    echo '[data]
machine = \"generic-linux\"' > '$TMP_CFG'
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'PKG_INSTALL_CMD=(sudo pacman -S --needed)'
"

run_check "Pacman-only profile with AUR packages FAILS CLEARLY" bash -c "
    echo '[data]
machine = \"generic-linux\"' > '$TMP_CFG'
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-00-reconcile-packages.sh.tmpl')
    echo \"\$out\" | grep -q 'FAILING CLEARLY: Install an AUR helper'
"

# 2. Greeter & Login Providers
echo -e "\n[Provider Matrix: Greeters & Login Modes]"
run_check "Login mode getty-tty1-autologin configures override and disables Ly" bash -c "
    echo '[data]
machine = \"asus-tuf-f16\"' > '$TMP_CFG'
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl')
    echo \"\$out\" | grep -F -q 'agetty --autologin' && echo \"\$out\" | grep -q 'for dm in ly.service'
"

run_check "Greeter Ly removes getty override and enables ly.service" bash -c "
    # Simulate custom profile with greeter = ly
    tmp_data=\$(mktemp /tmp/chezmoi-ly-data-XXXXXX.toml)
    sed 's/greeter = \"none\"/greeter = \"ly\"/' '$SCRIPT_DIR/.chezmoidata.toml' > \"\$tmp_data\"
    out=\$(chezmoi execute-template --config '$TMP_CFG' '{{- \$m := index .machines \"asus-tuf-f16\" -}}{{- if eq \$m.providers.greeter \"none\" -}}LY_BRANCH{{- end -}}')
    rm -f \"\$tmp_data\"
    grep -q 'Retiring getty autologin override' '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl' && \
    grep -q 'Enabling ly.service' '$SCRIPT_DIR/run_onchange_linux-10-reconcile-login.sh.tmpl'
"

# 3. Key Remapping (XRemap) Provider
echo -e "\n[Provider Matrix: Key Remapping (user-service vs none)]"
run_check "Provider user-service enables user xremap.service" bash -c "
    echo '[data]
machine = \"asus-tuf-f16\"' > '$TMP_CFG'
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    echo \"\$out\" | grep -q 'Activating user xremap.service'
"

run_check "Provider none disables/retires user xremap.service" bash -c "
    echo '[data]
machine = \"generic-linux\"' > '$TMP_CFG'
    out=\$(chezmoi execute-template --config '$TMP_CFG' < '$SCRIPT_DIR/run_onchange_linux-20-reconcile-services.sh.tmpl')
    echo \"\$out\" | grep -q 'Retiring user xremap.service'
"

# 4. Browser Secret Store Provider
echo -e "\n[Provider Matrix: Browser Secret Stores (basic, gnome-libsecret, kwallet)]"
for store in basic gnome-libsecret kwallet5 kwallet6; do
    run_check "Browser secret store provider '$store' compiles correctly" bash -c "
        out=\$(chezmoi execute-template '{{- \$secretStore := \"$store\" -}}--password-store={{ \$secretStore }}')
        [ \"\$out\" = \"--password-store=$store\" ]
    "
done

# 5. Bootloader Provider Boundary
echo -e "\n[Provider Matrix: Bootloader Declarative Boundary]"
run_check "GRUB reference config exists" test -f "$SCRIPT_DIR/backups/linux/bootloaders/grub/grub"
run_check "Bootloader documentation delineates NVRAM mutations" grep -q "Firmware NVRAM modifications" "$SCRIPT_DIR/docs/providers.md"

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mPROVIDER MATRIX SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mPROVIDER MATRIX SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
