#!/bin/bash
# test-inplace-sed.sh - Verify portable in-place sed helper
#
# Tests the inplace_sed() function works correctly on both macOS (BSD) and Linux (GNU).
#
# Usage:
#   ./scripts/tests/test-inplace-sed.sh
#
# Returns:
#   0 if all tests pass, 1 if any fail

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing inplace_sed()..."
echo ""

# Track test results
TESTS_RUN=0
TESTS_PASSED=0

# Helper to run a test
run_test() {
  local name="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  echo -n "  Test $TESTS_RUN: $name... "
}

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "PASS"
}

fail() {
  echo "FAIL"
  echo "    Expected: $1"
  echo "    Got:      $2"
}

# Create temp directory for tests
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# =============================================================================
# Test 1: Basic substitution
# =============================================================================
run_test "Basic substitution"
echo "hello world" > "$TEST_DIR/test1.txt"
inplace_sed 's/world/universe/' "$TEST_DIR/test1.txt"
result=$(cat "$TEST_DIR/test1.txt")
expected="hello universe"
if [ "$result" = "$expected" ]; then
  pass
else
  fail "$expected" "$result"
fi

# =============================================================================
# Test 2: Global substitution
# =============================================================================
run_test "Global substitution"
echo "foo foo foo" > "$TEST_DIR/test2.txt"
inplace_sed 's/foo/bar/g' "$TEST_DIR/test2.txt"
result=$(cat "$TEST_DIR/test2.txt")
expected="bar bar bar"
if [ "$result" = "$expected" ]; then
  pass
else
  fail "$expected" "$result"
fi

# =============================================================================
# Test 3: Special characters with alternate delimiter
# =============================================================================
run_test "Special characters with alternate delimiter"
echo "path/to/file" > "$TEST_DIR/test3.txt"
inplace_sed 's|path/to|new/path|' "$TEST_DIR/test3.txt"
result=$(cat "$TEST_DIR/test3.txt")
expected="new/path/file"
if [ "$result" = "$expected" ]; then
  pass
else
  fail "$expected" "$result"
fi

# =============================================================================
# Test 4: Markdown bold pattern (real-world use case)
# =============================================================================
run_test "Markdown bold pattern"
echo "**Last Updated:** 2025-01-01" > "$TEST_DIR/test4.txt"
inplace_sed 's/\*\*Last Updated:\*\* .*/\*\*Last Updated:\*\* 2026-01-14/' "$TEST_DIR/test4.txt"
result=$(cat "$TEST_DIR/test4.txt")
expected="**Last Updated:** 2026-01-14"
if [ "$result" = "$expected" ]; then
  pass
else
  fail "$expected" "$result"
fi

# =============================================================================
# Test 5: Missing file returns error
# =============================================================================
run_test "Missing file returns error"
if inplace_sed 's/a/b/' "$TEST_DIR/nonexistent.txt" 2>/dev/null; then
  fail "should return error" "returned success"
else
  pass
fi

# =============================================================================
# Test 6: Missing expression returns error
# =============================================================================
run_test "Missing expression returns error"
echo "test" > "$TEST_DIR/test6.txt"
if inplace_sed "" "$TEST_DIR/test6.txt" 2>/dev/null; then
  fail "should return error" "returned success"
else
  pass
fi

# =============================================================================
# Test 7: Missing file argument returns error
# =============================================================================
run_test "Missing file argument returns error"
if inplace_sed 's/a/b/' 2>/dev/null; then
  fail "should return error" "returned success"
else
  pass
fi

# =============================================================================
# Test 8: Multiple lines
# =============================================================================
run_test "Multiple lines"
cat > "$TEST_DIR/test8.txt" << 'EOF'
line one
line two
line three
EOF
inplace_sed 's/line/row/g' "$TEST_DIR/test8.txt"
result=$(cat "$TEST_DIR/test8.txt")
expected="row one
row two
row three"
if [ "$result" = "$expected" ]; then
  pass
else
  fail "$expected" "$result"
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
  echo "PASS: All $TESTS_RUN tests passed"
  exit 0
else
  echo "FAIL: $TESTS_PASSED/$TESTS_RUN tests passed"
  exit 1
fi
