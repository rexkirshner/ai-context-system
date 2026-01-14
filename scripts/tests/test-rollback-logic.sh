#!/bin/bash
# test-rollback-logic.sh - Validate rollback script structure and logic
# Tests that rollback.sh is safe and handles edge cases

set -e

echo "=== Rollback Script Logic Tests ==="
echo ""

PASS=0
FAIL=0

check() {
  if eval "$1" > /dev/null 2>&1; then
    echo "✓ $2"
    PASS=$((PASS + 1))
  else
    echo "✗ $2"
    FAIL=$((FAIL + 1))
  fi
}

ROLLBACK_SCRIPT="scripts/rollback.sh"

echo "--- Script Structure ---"
check "test -f '$ROLLBACK_SCRIPT'" "rollback.sh exists"
check "test -x '$ROLLBACK_SCRIPT'" "rollback.sh is executable"
check "head -1 '$ROLLBACK_SCRIPT' | grep -q '#!/bin/bash'" "Has bash shebang"
check "grep -q 'set -e' '$ROLLBACK_SCRIPT'" "Uses set -e for safety"

echo ""
echo "--- Safety Checks ---"
# Must confirm before destructive action
check "grep -q 'read -p\|read -n' '$ROLLBACK_SCRIPT'" "Requires user confirmation"

# Must validate backup exists before proceeding
check "grep -q 'test -d.*BACKUP\|\\[ -d.*backup\\|\\[ ! -d' '$ROLLBACK_SCRIPT'" "Validates backup directory"

# Must not use rm -rf on root or with unquoted variables
# Safe: rm -rf "$dir" or rm -rf "${dir}"
# Unsafe: rm -rf $dir or rm -rf /
UNSAFE_RM=$(grep 'rm -rf' "$ROLLBACK_SCRIPT" | grep -cvE 'rm -rf "\$|rm -rf \$\{' || true)
UNSAFE_RM="${UNSAFE_RM:-0}"
check "[ $UNSAFE_RM -eq 0 ]" "All rm -rf uses quoted variables ($UNSAFE_RM unsafe)"

echo ""
echo "--- User Content Protection ---"
# Must verify critical files are preserved
check "grep -q 'CONTEXT.md' '$ROLLBACK_SCRIPT'" "Mentions CONTEXT.md preservation"
check "grep -q 'STATUS.md' '$ROLLBACK_SCRIPT'" "Mentions STATUS.md preservation"
check "grep -q 'DECISIONS.md' '$ROLLBACK_SCRIPT'" "Mentions DECISIONS.md preservation"
check "grep -q 'SESSIONS.md' '$ROLLBACK_SCRIPT'" "Mentions SESSIONS.md preservation"

echo ""
echo "--- Backup Handling ---"
# Should find most recent backup if not specified
check "grep -q 'ls -dt.*backup\|ls.*backup.*sort' '$ROLLBACK_SCRIPT'" "Can find most recent backup"

# Should validate backup has required components
check "grep -q 'REQUIRED_BACKUP\|required.*backup\|validate\|VERSION' '$ROLLBACK_SCRIPT'" "Validates backup contents"

echo ""
echo "--- Error Messaging ---"
# Should have helpful error messages
check "grep -q 'Error:\|ERROR:\|error' '$ROLLBACK_SCRIPT'" "Has error messages"

# Should provide usage instructions
check "grep -q 'Usage:\|usage' '$ROLLBACK_SCRIPT'" "Has usage instructions"

echo ""
echo "--- Logging ---"
# Should log what it's doing
check "grep -q 'echo.*Step\|echo.*Rollback\|echo.*Restoring' '$ROLLBACK_SCRIPT'" "Logs progress steps"

# Should preserve backup after rollback (not delete it)
check "grep -qi 'keep.*backup\|preserv.*backup\|Keeping backup' '$ROLLBACK_SCRIPT'" "Preserves backup after rollback"

echo ""
echo "--- Simulated Execution Test ---"
# Test that --help or invalid args don't crash
# (We can't actually run rollback without a backup)

# Check script syntax is valid
check "bash -n '$ROLLBACK_SCRIPT'" "Script syntax is valid"

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo "✅ ALL ROLLBACK LOGIC TESTS PASSED"
else
  echo "❌ SOME TESTS FAILED"
fi

exit $FAIL
