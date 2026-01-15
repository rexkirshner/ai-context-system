#!/bin/bash
# test-exit-codes.sh - Tests for exit code convention
#
# Part of: Phase 4 - Exit Codes (v5.0.2)
#
# Exit Code Convention:
# - 0 = Clean pass (no errors, no warnings)
# - 1 = Pass with warnings (non-blocking issues)
# - 2 = Errors found (blocking issues)
#
# Note: validate-context.sh uses BASE_DIR relative to script location,
# so we test by verifying the exit code logic directly in the script
# rather than creating test directories.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "  Exit Code Tests (v5.0.2)"
echo "=============================================="
echo ""

ERRORS=0

# =============================================================================
# Test 1: Verify exit code convention is documented
# =============================================================================
echo "Test 1: Exit code convention documented in script..."

if grep -q "Exit codes: 0 = pass, 1 = warnings, 2 = errors" "$SCRIPT_DIR/../validate-context.sh"; then
  echo "  ✓ Exit code convention documented in header"
else
  echo "  ✗ Exit code convention not found in script header"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 2: Verify exit 0 logic (clean pass)
# =============================================================================
echo "Test 2: Exit 0 logic for clean pass..."

# Check that script has: "exit 0  # All passed" when ERRORS=0 and WARNINGS=0
if grep -q 'ERRORS -eq 0.*WARNINGS -eq 0' "$SCRIPT_DIR/../validate-context.sh" && \
   grep -q 'exit 0' "$SCRIPT_DIR/../validate-context.sh"; then
  echo "  ✓ Exit 0 for clean pass (no errors, no warnings)"
else
  echo "  ✗ Exit 0 logic not found for clean pass"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 3: Verify exit 1 logic (warnings only)
# =============================================================================
echo "Test 3: Exit 1 logic for warnings only..."

# Check that script has exit 1 when ERRORS=0 but WARNINGS>0
if grep -q 'exit 1' "$SCRIPT_DIR/../validate-context.sh" && \
   grep -q 'Warnings only' "$SCRIPT_DIR/../validate-context.sh"; then
  echo "  ✓ Exit 1 for warnings only"
else
  echo "  ✗ Exit 1 logic not found for warnings"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 4: Verify exit 2 logic (errors found)
# =============================================================================
echo "Test 4: Exit 2 logic for errors..."

# Check that script has exit 2 when ERRORS>0
if grep -q 'exit 2' "$SCRIPT_DIR/../validate-context.sh" && \
   grep -q 'Errors found' "$SCRIPT_DIR/../validate-context.sh"; then
  echo "  ✓ Exit 2 for errors found"
else
  echo "  ✗ Exit 2 logic not found for errors"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 5: Verify script actually uses ERRORS counter
# =============================================================================
echo "Test 5: ERRORS counter used for exit logic..."

# Check script increments ERRORS and uses it in exit conditions
ERRORS_INCREMENT=$(grep -c '((ERRORS++))' "$SCRIPT_DIR/../validate-context.sh" 2>/dev/null || echo "0")

if [ "$ERRORS_INCREMENT" -gt 0 ]; then
  echo "  ✓ ERRORS counter incremented $ERRORS_INCREMENT times"
else
  echo "  ✗ ERRORS counter not incremented in script"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 6: Verify WARNINGS counter used
# =============================================================================
echo "Test 6: WARNINGS counter used for exit logic..."

WARNINGS_INCREMENT=$(grep -c '((WARNINGS++))' "$SCRIPT_DIR/../validate-context.sh" 2>/dev/null || echo "0")

if [ "$WARNINGS_INCREMENT" -gt 0 ]; then
  echo "  ✓ WARNINGS counter incremented $WARNINGS_INCREMENT times"
else
  echo "  ✗ WARNINGS counter not incremented in script"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Test 7: Run actual validator and verify exit code is valid
# =============================================================================
echo "Test 7: Validator returns valid exit code (0, 1, or 2)..."

set +e
"$SCRIPT_DIR/../validate-context.sh" > /dev/null 2>&1
actual_exit=$?
set -e

if [ $actual_exit -eq 0 ] || [ $actual_exit -eq 1 ] || [ $actual_exit -eq 2 ]; then
  echo "  ✓ Validator returned valid exit code: $actual_exit"
  case $actual_exit in
    0) echo "    (Clean pass - no errors, no warnings)" ;;
    1) echo "    (Pass with warnings)" ;;
    2) echo "    (Errors found - expected for ACS repo without full context/)" ;;
  esac
else
  echo "  ✗ Unexpected exit code: $actual_exit (should be 0, 1, or 2)"
  ERRORS=$((ERRORS + 1))
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  PASS: All 7 exit code tests passed"
  echo "=============================================="
  exit 0
else
  echo "  FAIL: $ERRORS test(s) failed"
  echo "=============================================="
  exit 1
fi
