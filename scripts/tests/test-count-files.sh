#!/bin/bash
# test-count-files.sh - Verify deterministic file counting helper
#
# Tests the count_files() function returns correct counts on both
# macOS and Linux without being affected by shell aliases or options.
#
# Usage:
#   ./scripts/tests/test-count-files.sh
#
# Returns:
#   0 if all tests pass, 1 if any fail

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing count_files()..."
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
# Test 1: Count markdown files
# =============================================================================
run_test "Count markdown files"
mkdir -p "$TEST_DIR/test1"
touch "$TEST_DIR/test1/a.md" "$TEST_DIR/test1/b.md" "$TEST_DIR/test1/c.md"
count=$(count_files "$TEST_DIR/test1" "*.md")
if [ "$count" -eq 3 ]; then
  pass
else
  fail "3" "$count"
fi

# =============================================================================
# Test 2: Count JSON files
# =============================================================================
run_test "Count JSON files"
mkdir -p "$TEST_DIR/test2"
touch "$TEST_DIR/test2/a.json" "$TEST_DIR/test2/b.json"
count=$(count_files "$TEST_DIR/test2" "*.json")
if [ "$count" -eq 2 ]; then
  pass
else
  fail "2" "$count"
fi

# =============================================================================
# Test 3: Count all files (default pattern)
# =============================================================================
run_test "Count all files (default pattern)"
mkdir -p "$TEST_DIR/test3"
touch "$TEST_DIR/test3/file1.txt" "$TEST_DIR/test3/file2.md" "$TEST_DIR/test3/file3.json"
count=$(count_files "$TEST_DIR/test3")
if [ "$count" -eq 3 ]; then
  pass
else
  fail "3" "$count"
fi

# =============================================================================
# Test 4: Non-existent directory returns 0
# =============================================================================
run_test "Non-existent directory returns 0"
count=$(count_files "$TEST_DIR/nonexistent" "*.md")
if [ "$count" -eq 0 ]; then
  pass
else
  fail "0" "$count"
fi

# =============================================================================
# Test 5: Empty directory returns 0
# =============================================================================
run_test "Empty directory returns 0"
mkdir -p "$TEST_DIR/test5"
count=$(count_files "$TEST_DIR/test5" "*.md")
if [ "$count" -eq 0 ]; then
  pass
else
  fail "0" "$count"
fi

# =============================================================================
# Test 6: Doesn't count subdirectories
# =============================================================================
run_test "Doesn't count subdirectories"
mkdir -p "$TEST_DIR/test6/subdir"
touch "$TEST_DIR/test6/file1.md" "$TEST_DIR/test6/file2.md"
touch "$TEST_DIR/test6/subdir/file3.md"  # Should NOT be counted
count=$(count_files "$TEST_DIR/test6" "*.md")
if [ "$count" -eq 2 ]; then
  pass
else
  fail "2" "$count"
fi

# =============================================================================
# Test 7: Doesn't count directories named like files
# =============================================================================
run_test "Doesn't count directories named like files"
mkdir -p "$TEST_DIR/test7"
touch "$TEST_DIR/test7/real.md"
mkdir "$TEST_DIR/test7/fake.md"  # Directory, should NOT be counted
count=$(count_files "$TEST_DIR/test7" "*.md")
if [ "$count" -eq 1 ]; then
  pass
else
  fail "1" "$count"
fi

# =============================================================================
# Test 8: Pattern with specific prefix
# =============================================================================
run_test "Pattern with specific prefix"
mkdir -p "$TEST_DIR/test8"
touch "$TEST_DIR/test8/security-audit-01.md"
touch "$TEST_DIR/test8/security-audit-02.md"
touch "$TEST_DIR/test8/performance-audit-01.md"
count=$(count_files "$TEST_DIR/test8" "security-audit-*.md")
if [ "$count" -eq 2 ]; then
  pass
else
  fail "2" "$count"
fi

# =============================================================================
# Test 9: Files with spaces in names
# =============================================================================
run_test "Files with spaces in names"
mkdir -p "$TEST_DIR/test9"
touch "$TEST_DIR/test9/file with spaces.md"
touch "$TEST_DIR/test9/another file.md"
count=$(count_files "$TEST_DIR/test9" "*.md")
if [ "$count" -eq 2 ]; then
  pass
else
  fail "2" "$count"
fi

# =============================================================================
# Test 10: Missing directory argument returns error
# =============================================================================
run_test "Missing directory argument returns error"
# Use subshell to avoid set -e exiting the script
if count=$(count_files 2>/dev/null); then
  fail "error return code" "success (count=$count)"
else
  # Should return 1 (error) and echo "0"
  if [ "$count" = "0" ]; then
    pass
  else
    fail "output 0" "$count"
  fi
fi

# =============================================================================
# Test 11: Real-world: count agent files structure
# =============================================================================
run_test "Real-world: count agent files structure"
mkdir -p "$TEST_DIR/test11/agents"
touch "$TEST_DIR/test11/agents/code-reviewer.md"
touch "$TEST_DIR/test11/agents/security-reviewer.md"
touch "$TEST_DIR/test11/agents/performance-reviewer.md"
touch "$TEST_DIR/test11/agents/accessibility-reviewer.md"
count=$(count_files "$TEST_DIR/test11/agents" "*.md")
if [ "$count" -eq 4 ]; then
  pass
else
  fail "4" "$count"
fi

# =============================================================================
# Test 12: Hidden files (dotfiles)
# =============================================================================
run_test "Hidden files counted when pattern matches"
mkdir -p "$TEST_DIR/test12"
touch "$TEST_DIR/test12/.hidden" "$TEST_DIR/test12/.another"
touch "$TEST_DIR/test12/visible"
count=$(count_files "$TEST_DIR/test12" ".*")
if [ "$count" -eq 2 ]; then
  pass
else
  fail "2" "$count"
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
