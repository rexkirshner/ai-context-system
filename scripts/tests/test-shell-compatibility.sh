#!/bin/bash
# test-shell-compatibility.sh - Test shell compatibility for v5.1.0
#
# Tests that critical functions work correctly in both bash and zsh.
# This is important because macOS uses zsh by default.
#
# Version: 5.1.0
# Part of: Phase 1 - Shell Compatibility

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0

echo "=============================================="
echo "  Shell Compatibility Tests (v5.1.0)"
echo "=============================================="
echo ""

# Create a portable test script that can be run by any POSIX shell
TEST_SCRIPT=$(mktemp)
trap "rm -f $TEST_SCRIPT" EXIT

cat > "$TEST_SCRIPT" << 'TESTEOF'
#!/bin/sh
# Portable test script - runs in bash, zsh, sh

test_errors=0

echo "  Test 1: grep -c with no matches (single file)..."
echo "no match here" > /tmp/shell-test-$$.txt
count=$(grep -c "NOTFOUND" /tmp/shell-test-$$.txt 2>/dev/null || echo "0")
# Strip whitespace and ensure single value
count=$(echo "$count" | tr -d '[:space:]' | head -c 10)
count=$((count + 0))  # Force numeric
if [ "$count" -eq 0 ]; then
  echo "    ✓ grep -c empty result handled correctly"
else
  echo "    ✗ Expected 0, got '$count'"
  test_errors=$((test_errors + 1))
fi
rm -f /tmp/shell-test-$$.txt

echo "  Test 1b: grep -c on echoed variable (the actual bug case)..."
# This is the actual pattern from organize-docs: echo "$VAR" | grep -c
EMPTY_RESULT=""
count=$(echo "$EMPTY_RESULT" | grep -c "\.md$" 2>/dev/null || echo "0")
count=$(echo "$count" | tr -d '[:space:]' | head -c 10)
count=$((count + 0))
if [ "$count" -eq 0 ]; then
  echo "    ✓ grep -c on echoed empty variable works"
else
  echo "    ✗ Expected 0, got '$count'"
  test_errors=$((test_errors + 1))
fi

echo "  Test 2: Function-based file move..."
mkdir -p /tmp/mv-test-$$
echo "content" > /tmp/mv-test-$$/file.txt

# Simplified move_file for testing
move_file() {
  source="$1"
  dest="$2"

  # Validate source
  if [ ! -e "$source" ]; then
    echo "Error: Source does not exist" >&2
    return 1
  fi

  # Create dest dir
  dest_dir=$(dirname "$dest")
  if [ ! -d "$dest_dir" ]; then
    mkdir -p "$dest_dir" || return 1
  fi

  mv "$source" "$dest"
}

move_file /tmp/mv-test-$$/file.txt /tmp/mv-test-$$/moved.txt
if [ -f /tmp/mv-test-$$/moved.txt ]; then
  echo "    ✓ Function-based move works"
else
  echo "    ✗ Function-based move failed"
  test_errors=$((test_errors + 1))
fi

echo "  Test 3: move_file creates directories..."
echo "new content" > /tmp/mv-test-$$/new.txt
move_file /tmp/mv-test-$$/new.txt /tmp/mv-test-$$/deep/subdir/new.txt
if [ -f /tmp/mv-test-$$/deep/subdir/new.txt ]; then
  echo "    ✓ Directory creation works"
else
  echo "    ✗ Directory creation failed"
  test_errors=$((test_errors + 1))
fi

echo "  Test 4: move_file validates source..."
move_file /tmp/mv-test-$$/nonexistent.txt /tmp/mv-test-$$/dest.txt 2>/dev/null
result=$?
if [ $result -ne 0 ]; then
  echo "    ✓ Missing source detected correctly"
else
  echo "    ✗ Should have failed for missing source"
  test_errors=$((test_errors + 1))
fi

echo "  Test 5: Arithmetic with empty variables..."
EMPTY_VAR=""
# This would fail in zsh without protection
SAFE_VAL=$(echo "${EMPTY_VAR:-0}" | tr -d ' ')
SAFE_VAL=$((SAFE_VAL + 0))
if [ "$SAFE_VAL" -eq 0 ]; then
  echo "    ✓ Empty variable arithmetic works"
else
  echo "    ✗ Empty variable handling failed"
  test_errors=$((test_errors + 1))
fi

rm -rf /tmp/mv-test-$$
exit $test_errors
TESTEOF

chmod +x "$TEST_SCRIPT"

# Run tests in BASH
echo "=== Running in bash ==="
if bash "$TEST_SCRIPT"; then
  echo "  bash: ALL TESTS PASSED"
else
  echo "  bash: SOME TESTS FAILED"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# Run tests in ZSH (if available)
if command -v zsh > /dev/null 2>&1; then
  echo "=== Running in zsh ==="
  if zsh "$TEST_SCRIPT"; then
    echo "  zsh: ALL TESTS PASSED"
  else
    echo "  zsh: SOME TESTS FAILED"
    ERRORS=$((ERRORS + 1))
  fi
  echo ""
else
  echo "=== zsh not available, skipping ==="
  echo "  (This is fine for CI environments without zsh)"
  echo ""
fi

# Run tests in sh (POSIX baseline)
echo "=== Running in sh (POSIX) ==="
if sh "$TEST_SCRIPT"; then
  echo "  sh: ALL TESTS PASSED"
else
  echo "  sh: SOME TESTS FAILED"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
  echo "  PASS: All shell compatibility tests passed"
  echo "=============================================="
  exit 0
else
  echo "  FAIL: $ERRORS shell(s) had failures"
  echo "=============================================="
  exit 1
fi
