#!/bin/bash
# test-session-numbering.sh - Verify session number calculation
#
# Tests that get_next_session_number() returns MAX+1 (not COUNT+1),
# correctly handling gaps from session archiving.
#
# Usage:
#   ./scripts/tests/test-session-numbering.sh
#
# Returns:
#   0 if all tests pass, 1 if any fail

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing session numbering..."
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
# Test 1: No SESSIONS.md file
# =============================================================================
run_test "No SESSIONS.md file"
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "1" ]; then
  pass
else
  fail "1" "$result"
fi

# =============================================================================
# Test 2: Empty SESSIONS.md
# =============================================================================
run_test "Empty SESSIONS.md"
touch "$TEST_DIR/SESSIONS.md"
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "1" ]; then
  pass
else
  fail "1" "$result"
fi

# =============================================================================
# Test 3: Sequential sessions (1,2,3)
# =============================================================================
run_test "Sequential sessions (1,2,3)"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 3 | 2026-01-03 | Third Session
TL;DR: Did third thing

## Session 2 | 2026-01-02 | Second Session
TL;DR: Did second thing

## Session 1 | 2026-01-01 | First Session
TL;DR: Did first thing
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "4" ]; then
  pass
else
  fail "4" "$result"
fi

# =============================================================================
# Test 4: Gaps from archiving (5, 43, 44)
# =============================================================================
run_test "Gaps from archiving (5, 43, 44)"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 44 | 2026-01-14 | Latest Work
TL;DR: Most recent

## Session 43 | 2026-01-13 | Previous Work
TL;DR: Day before

## Session 5 | 2025-12-01 | Old Session
TL;DR: Old stuff
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "45" ]; then
  pass
else
  fail "45 (MAX+1, not COUNT+1=4)" "$result"
fi

# =============================================================================
# Test 5: Single high session (100)
# =============================================================================
run_test "Single high session (100)"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 100 | 2026-01-14 | Only Session
TL;DR: Just this one
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "101" ]; then
  pass
else
  fail "101" "$result"
fi

# =============================================================================
# Test 6: Dash format headers
# =============================================================================
run_test "Dash format headers"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 20 - 2026-01-14
Content here

## Session 15 - 2026-01-13
More content
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "21" ]; then
  pass
else
  fail "21" "$result"
fi

# =============================================================================
# Test 7: Mixed pipe and dash formats
# =============================================================================
run_test "Mixed pipe and dash formats"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 50 | 2026-01-14 | Pipe Format
Content

## Session 45 - 2026-01-13
Content

## Session 30 | 2026-01-12 | Another Pipe
Content
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "51" ]; then
  pass
else
  fail "51" "$result"
fi

# =============================================================================
# Test 8: Excludes Example section
# =============================================================================
run_test "Excludes Example section"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 10 | 2026-01-14 | Real Session
TL;DR: This is real

## Example Session Format
## Session 999 | Template
This should be ignored
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "11" ]; then
  pass
else
  fail "11 (ignoring 999 in example section)" "$result"
fi

# =============================================================================
# Test 9: Excludes Template keyword
# =============================================================================
run_test "Excludes Template keyword"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
# Session History

## Session 25 | 2026-01-14 | Real
Content

## Session Template
Don't count this

## Session 20 | 2026-01-13 | Also Real
Content
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "26" ]; then
  pass
else
  fail "26" "$result"
fi

# =============================================================================
# Test 10: get_max_session_number()
# =============================================================================
run_test "get_max_session_number()"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
## Session 44 | 2026-01-14 | Test
## Session 5 | 2025-12-01 | Old
EOF
result=$(get_max_session_number "$TEST_DIR")
if [ "$result" = "44" ]; then
  pass
else
  fail "44" "$result"
fi

# =============================================================================
# Test 11: Large session numbers
# =============================================================================
run_test "Large session numbers (500)"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
## Session 500 | 2026-01-14 | High Number
Content
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "501" ]; then
  pass
else
  fail "501" "$result"
fi

# =============================================================================
# Test 12: Session with extra text after number
# =============================================================================
run_test "Session with extra text after number"
cat > "$TEST_DIR/SESSIONS.md" << 'EOF'
## Session 75 | 2026-01-14 | Phase 3 - API Implementation
TL;DR: Working on APIs

## Session 74 | 2026-01-13 | Phase 2 Complete!
TL;DR: Done with phase 2
EOF
result=$(get_next_session_number "$TEST_DIR")
if [ "$result" = "76" ]; then
  pass
else
  fail "76" "$result"
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
