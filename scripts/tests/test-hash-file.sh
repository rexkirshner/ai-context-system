#!/bin/bash
# test-hash-file.sh - Verify portable file hashing helpers
#
# Tests the hash_file() and files_identical() functions work correctly
# on both macOS (BSD) and Linux (GNU).
#
# Usage:
#   ./scripts/tests/test-hash-file.sh
#
# Returns:
#   0 if all tests pass, 1 if any fail

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing hash_file() and files_identical()..."
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
# Test 1: Hash is 64 characters (SHA-256)
# =============================================================================
run_test "Hash is 64 characters (SHA-256)"
echo "test content" > "$TEST_DIR/test1.txt"
hash=$(hash_file "$TEST_DIR/test1.txt")
if [ ${#hash} -eq 64 ]; then
  pass
else
  fail "64 characters" "${#hash} characters"
fi

# =============================================================================
# Test 2: Same content produces same hash
# =============================================================================
run_test "Same content produces same hash"
echo "identical content" > "$TEST_DIR/test2a.txt"
echo "identical content" > "$TEST_DIR/test2b.txt"
hash_a=$(hash_file "$TEST_DIR/test2a.txt")
hash_b=$(hash_file "$TEST_DIR/test2b.txt")
if [ "$hash_a" = "$hash_b" ]; then
  pass
else
  fail "$hash_a" "$hash_b"
fi

# =============================================================================
# Test 3: Different content produces different hash
# =============================================================================
run_test "Different content produces different hash"
echo "content one" > "$TEST_DIR/test3a.txt"
echo "content two" > "$TEST_DIR/test3b.txt"
hash_a=$(hash_file "$TEST_DIR/test3a.txt")
hash_b=$(hash_file "$TEST_DIR/test3b.txt")
if [ "$hash_a" != "$hash_b" ]; then
  pass
else
  fail "different hashes" "same hash: $hash_a"
fi

# =============================================================================
# Test 4: Missing file returns error
# =============================================================================
run_test "Missing file returns error"
if hash_file "$TEST_DIR/nonexistent.txt" 2>/dev/null; then
  fail "should return error" "returned success"
else
  pass
fi

# =============================================================================
# Test 5: Missing argument returns error
# =============================================================================
run_test "Missing argument returns error"
if hash_file 2>/dev/null; then
  fail "should return error" "returned success"
else
  pass
fi

# =============================================================================
# Test 6: files_identical returns true for identical files
# =============================================================================
run_test "files_identical returns true for identical files"
echo "same same same" > "$TEST_DIR/test6a.txt"
echo "same same same" > "$TEST_DIR/test6b.txt"
if files_identical "$TEST_DIR/test6a.txt" "$TEST_DIR/test6b.txt"; then
  pass
else
  fail "files_identical to return true" "returned false"
fi

# =============================================================================
# Test 7: files_identical returns false for different files
# =============================================================================
run_test "files_identical returns false for different files"
echo "content A" > "$TEST_DIR/test7a.txt"
echo "content B" > "$TEST_DIR/test7b.txt"
if files_identical "$TEST_DIR/test7a.txt" "$TEST_DIR/test7b.txt"; then
  fail "files_identical to return false" "returned true"
else
  pass
fi

# =============================================================================
# Test 8: files_identical returns false if file missing
# =============================================================================
run_test "files_identical returns false if file missing"
echo "exists" > "$TEST_DIR/test8.txt"
if files_identical "$TEST_DIR/test8.txt" "$TEST_DIR/nonexistent.txt"; then
  fail "files_identical to return false" "returned true"
else
  pass
fi

# =============================================================================
# Test 9: Hash is consistent (deterministic)
# =============================================================================
run_test "Hash is consistent (deterministic)"
echo "deterministic test" > "$TEST_DIR/test9.txt"
hash1=$(hash_file "$TEST_DIR/test9.txt")
hash2=$(hash_file "$TEST_DIR/test9.txt")
hash3=$(hash_file "$TEST_DIR/test9.txt")
if [ "$hash1" = "$hash2" ] && [ "$hash2" = "$hash3" ]; then
  pass
else
  fail "all hashes equal" "hashes differ"
fi

# =============================================================================
# Test 10: Empty file has valid hash
# =============================================================================
run_test "Empty file has valid hash"
touch "$TEST_DIR/test10.txt"
hash=$(hash_file "$TEST_DIR/test10.txt")
# SHA-256 of empty file is well-known
expected="e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
if [ "$hash" = "$expected" ]; then
  pass
else
  fail "$expected" "$hash"
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
