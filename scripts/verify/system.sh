#!/usr/bin/env bash
# ==============================================================================
# Workstation Verification: Master System Verification Runner
# ==============================================================================
# Sequentially executes all 7 modular verification suites:
#   1. architecture.sh  - Data model, deduplication, generic fallback
#   2. profiles.sh      - Machine compilation matrix across OS targets
#   3. providers.sh     - Provider resolution & abstraction verification
#   4. packages.sh      - Package manifest closure & AUR boundaries
#   5. services.sh      - Service lifecycle & reconciliation logic
#   6. security.sh      - Secret scanning, Age crypto & boundary isolation
#   7. health.sh        - Live host runtime health verification
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERALL_STATUS=0
FAILED_SUITES=()
PASSED_SUITES=()

SUITES=(
    "architecture.sh:Architectural Data Model & Boundaries"
    "profiles.sh:Machine Profiles & Compilation Matrix"
    "providers.sh:Provider Resolution & Abstractions"
    "packages.sh:Package Closure & Manifests"
    "services.sh:Service Lifecycle & Reconciliation"
    "security.sh:Security & Secret Boundaries"
    "health.sh:Live Host Runtime Health"
)

echo "=============================================================================="
echo " EXECUTING MASTER WORKSTATION VERIFICATION SUITE"
echo " Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo " Target Machine: $(hostname 2>/dev/null || echo 'unknown')"
echo "=============================================================================="

for entry in "${SUITES[@]}"; do
    suite_file="${entry%%:*}"
    suite_name="${entry#*:}"
    suite_path="$SCRIPT_DIR/$suite_file"

    echo ""
    if [ -f "$suite_path" ]; then
        if bash "$suite_path"; then
            PASSED_SUITES+=("$suite_file ($suite_name)")
        else
            OVERALL_STATUS=1
            FAILED_SUITES+=("$suite_file ($suite_name)")
        fi
    else
        echo -e " \033[31m✖ ERROR\033[0m: Suite script $suite_file not found at $suite_path"
        OVERALL_STATUS=1
        FAILED_SUITES+=("$suite_file ($suite_name - MISSING)")
    fi
done

echo ""
echo "=============================================================================="
echo " MASTER VERIFICATION SUMMARY"
echo "=============================================================================="
echo " Passed Suites (${#PASSED_SUITES[@]}/${#SUITES[@]}):"
for s in "${PASSED_SUITES[@]}"; do
    echo -e "   \033[32m✔\033[0m $s"
done

if [ ${#FAILED_SUITES[@]} -gt 0 ]; then
    echo " Failed Suites (${#FAILED_SUITES[@]}/${#SUITES[@]}):"
    for s in "${FAILED_SUITES[@]}"; do
        echo -e "   \033[31m✖\033[0m $s"
    done
fi

echo "=============================================================================="
if [ $OVERALL_STATUS -eq 0 ]; then
    echo -e " \033[32mALL VERIFICATION SUITES PASSED SUCCESSFULLY\033[0m"
    echo "=============================================================================="
    exit 0
else
    echo -e " \033[31mONE OR MORE VERIFICATION SUITES FAILED\033[0m"
    echo "=============================================================================="
    exit 1
fi
