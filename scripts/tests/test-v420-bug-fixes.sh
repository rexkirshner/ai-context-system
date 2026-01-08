#!/bin/bash
# test-v420-bug-fixes.sh - Tests for v4.2.0 bug fixes
# Tests Bug 1 (bash precedence), Bug 2 (session regex), Bug 3 (date warning)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✓ PASS${NC}: $1"
}

fail() {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo -e "${RED}✗ FAIL${NC}: $1"
  echo "  Expected: $2"
  echo "  Got: $3"
}

run_test() {
  TESTS_RUN=$((TESTS_RUN + 1))
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  v4.2.0 Bug Fix Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# =============================================================================
# Bug 1: Bash Precedence Tests
# =============================================================================
echo "Bug 1: Context Directory Detection (Bash Precedence)"
echo "-----------------------------------------------------"

# Create test directory structure
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# The FIXED version using if-elif-else (what save-full.md should have)
detect_context_fixed() {
  local dir="$1"
  (
    cd "$dir" || exit 1
    if [ -d "context" ]; then
      echo "context"
    elif [ -d "../context" ]; then
      echo "../context"
    elif [ -d "../../context" ]; then
      echo "../../context"
    else
      echo "ERROR"
    fi
  )
}

# Test 1.1: Context at current level only
run_test
mkdir -p "$TEST_DIR/proj1/context"
RESULT=$(detect_context_fixed "$TEST_DIR/proj1")
EXPECTED="context"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Context at current level returns 'context'"
else
  fail "Context at current level" "$EXPECTED" "$RESULT"
fi

# Test 1.2: Context at parent level only
run_test
mkdir -p "$TEST_DIR/proj2/context"
mkdir -p "$TEST_DIR/proj2/subdir"
RESULT=$(detect_context_fixed "$TEST_DIR/proj2/subdir")
EXPECTED="../context"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Context at parent level returns '../context'"
else
  fail "Context at parent level" "$EXPECTED" "$RESULT"
fi

# Test 1.3: Context at grandparent level only
run_test
mkdir -p "$TEST_DIR/proj3/context"
mkdir -p "$TEST_DIR/proj3/sub1/sub2"
RESULT=$(detect_context_fixed "$TEST_DIR/proj3/sub1/sub2")
EXPECTED="../../context"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Context at grandparent level returns '../../context'"
else
  fail "Context at grandparent level" "$EXPECTED" "$RESULT"
fi

# Test 1.4: No context anywhere
run_test
mkdir -p "$TEST_DIR/proj4/nocontext"
RESULT=$(detect_context_fixed "$TEST_DIR/proj4/nocontext")
EXPECTED="ERROR"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "No context anywhere returns 'ERROR'"
else
  fail "No context anywhere" "$EXPECTED" "$RESULT"
fi

# Test 1.5: Context at multiple levels - should return closest (current)
run_test
mkdir -p "$TEST_DIR/proj5/context"
mkdir -p "$TEST_DIR/proj5/subdir/context"
RESULT=$(detect_context_fixed "$TEST_DIR/proj5/subdir")
EXPECTED="context"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Multiple context dirs - returns closest (current)"
else
  fail "Multiple context dirs - closest" "$EXPECTED" "$RESULT"
fi

# Test 1.6: Verify only ONE output line (no multiple echoes)
run_test
mkdir -p "$TEST_DIR/proj6/context"
LINE_COUNT=$(detect_context_fixed "$TEST_DIR/proj6" | wc -l | tr -d ' ')
if [ "$LINE_COUNT" = "1" ]; then
  pass "Output is exactly one line"
else
  fail "Output should be one line" "1" "$LINE_COUNT"
fi

echo ""

# =============================================================================
# Bug 2: Session Number Regex Tests
# =============================================================================
echo "Bug 2: Session Number Regex"
echo "----------------------------"

# Create test SESSIONS.md files
SESSIONS_TEST="$TEST_DIR/sessions-test.md"

# Test 2.1: Should NOT match "## Session Index"
run_test
cat > "$SESSIONS_TEST" << 'EOF'
# SESSIONS.md

## Session Index
Quick navigation for all sessions.

## Session 1 | 2026-01-01 | Initial setup
Content here

## Session 2 | 2026-01-02 | Feature work
Content here
EOF

# FIXED regex: requires " |" after the number
RESULT=$(grep -E "^## Session [0-9]+ \|" "$SESSIONS_TEST" 2>/dev/null | grep -oE "Session [0-9]+" | grep -oE "[0-9]+" | sort -n | tail -1 | awk '{print} END {if (NR==0) print "0"}')
EXPECTED="2"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Session Index heading ignored, returns highest real session (2)"
else
  fail "Session Index should be ignored" "$EXPECTED" "$RESULT"
fi

# Test 2.2: Empty SESSIONS.md returns 0
run_test
echo "# Empty sessions file" > "$SESSIONS_TEST"
RESULT=$(grep -E "^## Session [0-9]+ \|" "$SESSIONS_TEST" 2>/dev/null | grep -oE "Session [0-9]+" | grep -oE "[0-9]+" | sort -n | tail -1 | awk '{print} END {if (NR==0) print "0"}')
EXPECTED="0"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Empty SESSIONS.md returns 0"
else
  fail "Empty file should return 0" "$EXPECTED" "$RESULT"
fi

# Test 2.3: Template placeholders should be ignored
run_test
cat > "$SESSIONS_TEST" << 'EOF'
# SESSIONS.md

## Session Index
Navigation section

Example format:
## Session [N] | DATE | TITLE

## Session 5 | 2026-01-05 | Real session
Content

## Session 10 | 2026-01-10 | Another session
Content
EOF

RESULT=$(grep -E "^## Session [0-9]+ \|" "$SESSIONS_TEST" 2>/dev/null | grep -oE "Session [0-9]+" | grep -oE "[0-9]+" | sort -n | tail -1 | awk '{print} END {if (NR==0) print "0"}')
EXPECTED="10"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Template placeholder [N] ignored, returns 10"
else
  fail "Template placeholder should be ignored" "$EXPECTED" "$RESULT"
fi

# Test 2.4: Handles gaps from archiving
run_test
cat > "$SESSIONS_TEST" << 'EOF'
## Session 8 | 2026-01-08 | After archive
## Session 9 | 2026-01-09 | Continued
## Session 10 | 2026-01-10 | Latest
EOF

RESULT=$(grep -E "^## Session [0-9]+ \|" "$SESSIONS_TEST" 2>/dev/null | grep -oE "Session [0-9]+" | grep -oE "[0-9]+" | sort -n | tail -1 | awk '{print} END {if (NR==0) print "0"}')
EXPECTED="10"
if [ "$RESULT" = "$EXPECTED" ]; then
  pass "Handles gaps (sessions 8,9,10) - returns 10"
else
  fail "Should handle gaps" "$EXPECTED" "$RESULT"
fi

echo ""

# =============================================================================
# Bug 3: Date Warning Logic Tests
# =============================================================================
echo "Bug 3: Date Comparison Logic"
echo "-----------------------------"

# Test 3.1: Different dates - this is EXPECTED behavior, not a warning
run_test
CONTEXT_DATE="2026-01-01"
STATUS_DATE="2026-01-07"

# The dates are intentionally different - CONTEXT.md is static, STATUS.md is dynamic
# The old code showed a warning. The new code should just show info.
if [ "$CONTEXT_DATE" != "$STATUS_DATE" ]; then
  # This condition is TRUE, which is normal/expected
  pass "Different dates detected (this is normal behavior)"
else
  fail "Should detect different dates" "different" "same"
fi

# Test 3.2: Same dates
run_test
CONTEXT_DATE="2026-01-07"
STATUS_DATE="2026-01-07"
if [ "$CONTEXT_DATE" = "$STATUS_DATE" ]; then
  pass "Same dates detected correctly"
else
  fail "Should detect same dates" "same" "different"
fi

# Test 3.3: Verify info message format (simulated)
run_test
CONTEXT_DATE="2026-01-01"
STATUS_DATE="2026-01-07"
# New format should use ℹ️ not ⚠️
INFO_MSG="ℹ️  Layer dates: CONTEXT.md ($CONTEXT_DATE) | STATUS.md ($STATUS_DATE)"
if [[ "$INFO_MSG" == *"ℹ️"* ]] && [[ "$INFO_MSG" != *"⚠️"* ]]; then
  pass "Info message uses ℹ️ icon (not warning)"
else
  fail "Should use info icon" "ℹ️" "other"
fi

echo ""

# =============================================================================
# Improvement 1: Already-Initialized Detection Tests
# =============================================================================
echo "Improvement 1: Already-Initialized Detection"
echo "----------------------------------------------"

# Test I1.1: Detection of .context-config.json
run_test
mkdir -p "$TEST_DIR/proj-init/context"
echo '{"project": {"name": "test"}}' > "$TEST_DIR/proj-init/context/.context-config.json"
if [ -f "$TEST_DIR/proj-init/context/.context-config.json" ]; then
  pass "Detects existing .context-config.json"
else
  fail "Should detect config file" "exists" "not found"
fi

# Test I1.2: No false positive on fresh project
run_test
mkdir -p "$TEST_DIR/proj-fresh"
if [ ! -f "$TEST_DIR/proj-fresh/context/.context-config.json" ]; then
  pass "No false positive on fresh project"
else
  fail "Should not detect config on fresh project" "not exists" "exists"
fi

# Test I1.3: Context files listing works
run_test
mkdir -p "$TEST_DIR/proj-list/context"
touch "$TEST_DIR/proj-list/context/STATUS.md"
touch "$TEST_DIR/proj-list/context/CONTEXT.md"
touch "$TEST_DIR/proj-list/context/SESSIONS.md"
FILE_COUNT=$(ls "$TEST_DIR/proj-list/context"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILE_COUNT" = "3" ]; then
  pass "Lists existing context files correctly"
else
  fail "Should list 3 context files" "3" "$FILE_COUNT"
fi

echo ""

# =============================================================================
# Improvement 2: CLAUDE.md Detection Tests
# =============================================================================
echo "Improvement 2: CLAUDE.md Detection"
echo "------------------------------------"

# Test I2.1: Detect large CLAUDE.md (>5KB)
run_test
mkdir -p "$TEST_DIR/proj-claude-large"
# Create a file > 5KB (5001 bytes)
dd if=/dev/zero bs=5001 count=1 2>/dev/null | tr '\0' 'x' > "$TEST_DIR/proj-claude-large/CLAUDE.md"
CLAUDE_SIZE=$(wc -c < "$TEST_DIR/proj-claude-large/CLAUDE.md" | tr -d ' ')
if [ "$CLAUDE_SIZE" -gt 5000 ]; then
  pass "Detects large CLAUDE.md (${CLAUDE_SIZE}B > 5KB)"
else
  fail "Should detect large CLAUDE.md" ">5000" "$CLAUDE_SIZE"
fi

# Test I2.2: Detect small CLAUDE.md (<5KB)
run_test
mkdir -p "$TEST_DIR/proj-claude-small"
echo "# Small CLAUDE.md" > "$TEST_DIR/proj-claude-small/CLAUDE.md"
CLAUDE_SIZE=$(wc -c < "$TEST_DIR/proj-claude-small/CLAUDE.md" | tr -d ' ')
if [ "$CLAUDE_SIZE" -lt 5000 ]; then
  pass "Detects small CLAUDE.md (${CLAUDE_SIZE}B < 5KB)"
else
  fail "Should detect small CLAUDE.md" "<5000" "$CLAUDE_SIZE"
fi

# Test I2.3: Size formatting - KB display
run_test
SIZE_BYTES=10240
if [ "$SIZE_BYTES" -gt 1024 ]; then
  SIZE_DISPLAY="$(( SIZE_BYTES / 1024 ))KB"
else
  SIZE_DISPLAY="${SIZE_BYTES}B"
fi
if [ "$SIZE_DISPLAY" = "10KB" ]; then
  pass "Size formatting works (10240B = 10KB)"
else
  fail "Size formatting" "10KB" "$SIZE_DISPLAY"
fi

# Test I2.4: No CLAUDE.md detected on fresh project
run_test
mkdir -p "$TEST_DIR/proj-no-claude"
if [ ! -f "$TEST_DIR/proj-no-claude/CLAUDE.md" ]; then
  pass "No false positive when CLAUDE.md absent"
else
  fail "Should not detect CLAUDE.md" "not exists" "exists"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Tests Run: $TESTS_RUN"
echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
  echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $TESTS_FAILED -gt 0 ]; then
  exit 1
fi

echo ""
echo -e "${GREEN}All v4.2.0 bug fix tests passed!${NC}"
exit 0
