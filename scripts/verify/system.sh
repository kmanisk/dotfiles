#!/usr/bin/env bash
# ==============================================================================
# Workstation Verification: Master System Verification Suite
# ==============================================================================
# Runs both the Declarative Reproducibility Suite and the Live Host Health Suite.
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUS=0

echo "=============================================================================="
echo " EXECUTING MASTER WORKSTATION VERIFICATION SUITE"
echo "=============================================================================="

# 1. Run Declarative Architecture & Reproducibility Suite
if [ -f "$SCRIPT_DIR/reproducibility.sh" ]; then
    bash "$SCRIPT_DIR/reproducibility.sh" || STATUS=1
else
    echo "Error: reproducibility.sh not found!"
    STATUS=1
fi

echo ""

# 2. Run Live Host Runtime Health Suite
if [ -f "$SCRIPT_DIR/health.sh" ]; then
    bash "$SCRIPT_DIR/health.sh" || STATUS=1
else
    echo "Error: health.sh not found!"
    STATUS=1
fi

echo ""
echo "=============================================================================="
if [ $STATUS -eq 0 ]; then
    echo -e " \033[32mOVERALL VERIFICATION RESULT: ALL SUITES PASSED\033[0m"
    echo "=============================================================================="
    exit 0
else
    echo -e " \033[31mOVERALL VERIFICATION RESULT: ONE OR MORE SUITES FAILED\033[0m"
    echo "=============================================================================="
    exit 1
fi
