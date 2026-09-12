#!/usr/bin/env bash
# ==============================================================================
# Suite 6: Security & Secret Boundary Verification
# ==============================================================================
# Audits working tree and commit history for private keys, plaintext tokens,
# passwords, and evaluates age encryption architecture and ignore boundaries.
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
echo " [SUITE 6/7] SECURITY & SECRET BOUNDARY VERIFICATION"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "=============================================================================="

# 1. Working Tree Secret Scanning
echo -e "\n[Category: Working Tree Secret Scanning]"
run_check "Zero unencrypted private keys in working tree" bash -c "
    ! git -C '$SCRIPT_DIR' grep -EI 'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY' -- ':!scripts/verify/*'
"
run_check "Zero unencrypted GitHub tokens in working tree" bash -c "
    ! git -C '$SCRIPT_DIR' grep -EI 'ghp_[a-zA-Z0-9]{20,}|github_pat_[a-zA-Z0-9_]{20,}' -- ':!scripts/verify/*'
"
run_check "Zero AWS access keys in working tree" bash -c "
    ! git -C '$SCRIPT_DIR' grep -EI 'AKIA[0-9A-Z]{16}' -- ':!scripts/verify/*'
"
run_check "Zero Slack / Discord webhook tokens in working tree" bash -c "
    ! git -C '$SCRIPT_DIR' grep -EI 'https://hooks.slack.com/services/|https://discord(app)?.com/api/webhooks/' -- ':!scripts/verify/*'
"

# 2. Git Commit History Scanning
echo -e "\n[Category: Git History Secret Scanning]"
run_check "Zero private keys across git commit history (git log -p)" bash -c "
    ! git -C '$SCRIPT_DIR' log -p | grep -EI '^\+[^+].*BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY' | grep -v 'scripts/verify'
"
run_check "Zero GitHub tokens across git commit history (git log -p)" bash -c "
    ! git -C '$SCRIPT_DIR' log -p | grep -EI '^\+[^+].*(ghp_[a-zA-Z0-9]{20,}|github_pat_[a-zA-Z0-9_]{20,})' | grep -v 'scripts/verify'
"

# 3. Encryption Configuration Integrity
echo -e "\n[Category: Chezmoi Age Encryption Integrity]"
run_check "Chezmoi config specifies age encryption engine" bash -c "
    grep -q 'encryption = \"age\"' '$SCRIPT_DIR/.chezmoi.toml.tmpl'
"
run_check "Chezmoi config defines age recipient configuration" bash -c "
    grep -q '\[age\]' '$SCRIPT_DIR/.chezmoi.toml.tmpl' && grep -q 'recipient = ' '$SCRIPT_DIR/.chezmoi.toml.tmpl'
"
run_check "No raw secrets stored in .chezmoidata.toml" bash -c "
    ! grep -iE 'token|secret|password|api_key' '$SCRIPT_DIR/.chezmoidata.toml' | grep -qv 'browser_secret_store'
"

# 4. Browser Keyring Isolation Guard
echo -e "\n[Category: Browser Keyring Isolation]"
run_check "brave-flags template sets browser password store parameter" bash -c "
    grep -q 'password-store={{ \$secretStore }}' '$SCRIPT_DIR/dot_config/brave-flags.conf.tmpl'
"
run_check "brave-origin-flags template sets browser password store parameter" bash -c "
    grep -q 'password-store={{ \$secretStore }}' '$SCRIPT_DIR/dot_config/brave-origin-flags.conf.tmpl'
"

# 5. Boundary Protection (.chezmoiignore)
echo -e "\n[Category: Target Boundary & Exclusion Isolation]"
for dir in backups docs scripts packages hardware systemd btrfs; do
    run_check "Internal directory $dir ignored from \$HOME deployment" grep -q "^$dir/\*\*" "$SCRIPT_DIR/.chezmoiignore"
done

echo "=============================================================================="
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e " \033[32mSECURITY & SECRET SUITE PASSED\033[0m ($TOTAL_CHECKS/$TOTAL_CHECKS)"
    exit 0
else
    echo -e " \033[31mSECURITY & SECRET SUITE FAILED\033[0m ($FAILED_CHECKS failed out of $TOTAL_CHECKS checks)"
    exit 1
fi
