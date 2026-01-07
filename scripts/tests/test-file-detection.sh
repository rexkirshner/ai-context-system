#!/bin/bash

# test-file-detection.sh
# Tests file existence detection for /save-full command
# Version: 4.0.2

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing File Detection for /save-full"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create temp test directory
TEST_DIR=$(mktemp -d)
CONTEXT_DIR="$TEST_DIR/context"
mkdir -p "$CONTEXT_DIR"

echo "Test directory: $TEST_DIR"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function for assertions
assert_contains() {
  local output="$1"
  local expected="$2"
  local test_name="$3"

  if echo "$output" | grep -q "$expected"; then
    echo -e "  ${GREEN}✅ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}❌ FAIL${NC}: $test_name"
    echo "    Expected to find: $expected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_not_contains() {
  local output="$1"
  local unexpected="$2"
  local test_name="$3"

  if ! echo "$output" | grep -q "$unexpected"; then
    echo -e "  ${GREEN}✅ PASS${NC}: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "  ${RED}❌ FAIL${NC}: $test_name"
    echo "    Should NOT find: $unexpected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# ============================================================
# Test 1: All files present
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: All context files present"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create all files
touch "$CONTEXT_DIR/CONTEXT.md"
touch "$CONTEXT_DIR/STATUS.md"
touch "$CONTEXT_DIR/DECISIONS.md"
touch "$CONTEXT_DIR/SESSIONS.md"
echo '{"name": "test"}' > "$CONTEXT_DIR/.context-config.json"

# Run detection script
OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
echo "📁 Detecting available context files..."
echo ""
echo "Core files:"
test -f "$CONTEXT_DIR/CONTEXT.md" && echo "  ✅ CONTEXT.md" || echo "  ⚠️ CONTEXT.md not found"
test -f "$CONTEXT_DIR/STATUS.md" && echo "  ✅ STATUS.md" || echo "  ⚠️ STATUS.md not found"
test -f "$CONTEXT_DIR/DECISIONS.md" && echo "  ✅ DECISIONS.md" || echo "  ⚠️ DECISIONS.md not found"
test -f "$CONTEXT_DIR/SESSIONS.md" && echo "  ✅ SESSIONS.md" || echo "  ⚠️ SESSIONS.md not found"
SCRIPT
)

assert_contains "$OUTPUT" "✅ CONTEXT.md" "CONTEXT.md detected"
assert_contains "$OUTPUT" "✅ STATUS.md" "STATUS.md detected"
assert_contains "$OUTPUT" "✅ DECISIONS.md" "DECISIONS.md detected"
assert_contains "$OUTPUT" "✅ SESSIONS.md" "SESSIONS.md detected"
assert_not_contains "$OUTPUT" "not found" "No missing file warnings"
echo ""

# ============================================================
# Test 2: STATUS.md missing
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: STATUS.md missing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rm -f "$CONTEXT_DIR/STATUS.md"

OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
echo "Core files:"
test -f "$CONTEXT_DIR/CONTEXT.md" && echo "  ✅ CONTEXT.md" || echo "  ⚠️ CONTEXT.md not found"
test -f "$CONTEXT_DIR/STATUS.md" && echo "  ✅ STATUS.md" || echo "  ⚠️ STATUS.md not found"
test -f "$CONTEXT_DIR/DECISIONS.md" && echo "  ✅ DECISIONS.md" || echo "  ⚠️ DECISIONS.md not found"
test -f "$CONTEXT_DIR/SESSIONS.md" && echo "  ✅ SESSIONS.md" || echo "  ⚠️ SESSIONS.md not found"
echo ""
echo "Steps affected by missing files:"
test -f "$CONTEXT_DIR/STATUS.md" || echo "  • Step 4 (STATUS.md update) - will skip"
test -f "$CONTEXT_DIR/STATUS.md" || echo "  • Step 6 (Quick Reference) - will skip"
SCRIPT
)

assert_contains "$OUTPUT" "✅ CONTEXT.md" "CONTEXT.md still detected"
assert_contains "$OUTPUT" "⚠️ STATUS.md not found" "STATUS.md missing detected"
assert_contains "$OUTPUT" "Step 4" "Step 4 skip warning shown"
assert_contains "$OUTPUT" "Step 6" "Step 6 skip warning shown"
echo ""

# ============================================================
# Test 3: Multiple files missing - suggest init
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Multiple files missing (should suggest /init-context)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rm -f "$CONTEXT_DIR/SESSIONS.md"
rm -f "$CONTEXT_DIR/DECISIONS.md"

OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
MISSING_COUNT=0
test -f "$CONTEXT_DIR/CONTEXT.md" || MISSING_COUNT=$((MISSING_COUNT + 1))
test -f "$CONTEXT_DIR/STATUS.md" || MISSING_COUNT=$((MISSING_COUNT + 1))
test -f "$CONTEXT_DIR/SESSIONS.md" || MISSING_COUNT=$((MISSING_COUNT + 1))

if [ "$MISSING_COUNT" -gt 1 ]; then
  echo "💡 Multiple core files missing. Consider running /init-context to set up the full context system."
fi
SCRIPT
)

assert_contains "$OUTPUT" "/init-context" "Suggests /init-context when multiple files missing"
echo ""

# ============================================================
# Test 4: Final report with missing files
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: Final report shows skipped files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Only CONTEXT.md exists
OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
echo "Core Updates:"
if [ -f "$CONTEXT_DIR/SESSIONS.md" ]; then
  echo "  ✅ SESSIONS.md - Comprehensive session entry"
else
  echo "  ⚠️ SESSIONS.md - Skipped (file not found)"
fi

if [ -f "$CONTEXT_DIR/STATUS.md" ]; then
  echo "  ✅ STATUS.md - Updated"
else
  echo "  ⚠️ STATUS.md - Skipped (file not found)"
fi

SKIPPED_COUNT=0
test -f "$CONTEXT_DIR/SESSIONS.md" || SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
test -f "$CONTEXT_DIR/STATUS.md" || SKIPPED_COUNT=$((SKIPPED_COUNT + 1))

if [ "$SKIPPED_COUNT" -gt 0 ]; then
  echo "💡 Some files were skipped. Run /init-context to create missing files."
fi
SCRIPT
)

assert_contains "$OUTPUT" "⚠️ SESSIONS.md - Skipped" "Shows SESSIONS.md skipped"
assert_contains "$OUTPUT" "⚠️ STATUS.md - Skipped" "Shows STATUS.md skipped"
assert_contains "$OUTPUT" "Some files were skipped" "Shows skip summary"
echo ""

# ============================================================
# Test 5: /save - STATUS.md exists
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 5: /save - STATUS.md exists"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Recreate STATUS.md
touch "$CONTEXT_DIR/STATUS.md"

OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
echo "📁 Checking context files..."
if [ -f "$CONTEXT_DIR/STATUS.md" ]; then
  echo "  ✅ STATUS.md found"
else
  echo "  ⚠️ STATUS.md not found"
fi
SCRIPT
)

assert_contains "$OUTPUT" "✅ STATUS.md found" "/save detects STATUS.md"
echo ""

# ============================================================
# Test 6: /save - STATUS.md missing
# ============================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 6: /save - STATUS.md missing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

rm -f "$CONTEXT_DIR/STATUS.md"

OUTPUT=$(cat <<'SCRIPT' | CONTEXT_DIR="$CONTEXT_DIR" bash
echo "📁 Checking context files..."
if [ -f "$CONTEXT_DIR/STATUS.md" ]; then
  echo "  ✅ STATUS.md found"
else
  echo "  ⚠️ STATUS.md not found"
  echo "  /save primarily updates STATUS.md."
  echo "  💡 Run /init-context to create full context system"
fi
SCRIPT
)

assert_contains "$OUTPUT" "⚠️ STATUS.md not found" "/save detects missing STATUS.md"
assert_contains "$OUTPUT" "/init-context" "/save suggests init-context"
echo ""

# ============================================================
# Cleanup and Summary
# ============================================================
rm -rf "$TEST_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  ${GREEN}Passed${NC}: $TESTS_PASSED"
echo -e "  ${RED}Failed${NC}: $TESTS_FAILED"
echo ""

if [ "$TESTS_FAILED" -eq 0 ]; then
  echo -e "${GREEN}✅ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi
