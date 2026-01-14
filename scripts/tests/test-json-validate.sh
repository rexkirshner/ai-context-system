#!/bin/bash
# test-json-validate.sh - Verify portable JSON validation helper
#
# Tests the json_validate() function works correctly with different
# JSON validators (jq, python3, python).
#
# Usage:
#   ./scripts/tests/test-json-validate.sh
#
# Returns:
#   0 if all tests pass, 1 if any fail

set -e

# Get script directory and source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../common-functions.sh"

echo "Testing json_validate()..."
echo ""

# Report which validator is available
if command -v jq &>/dev/null; then
  echo "Using validator: jq"
elif command -v python3 &>/dev/null; then
  echo "Using validator: python3"
elif command -v python &>/dev/null; then
  echo "Using validator: python"
else
  echo "No validator available - tests may be skipped"
fi
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
# Test 1: Valid simple JSON object
# =============================================================================
run_test "Valid simple JSON object"
echo '{"name": "test", "value": 123}' > "$TEST_DIR/test1.json"
if json_validate "$TEST_DIR/test1.json"; then
  pass
else
  fail "validation to pass" "validation failed"
fi

# =============================================================================
# Test 2: Valid JSON array
# =============================================================================
run_test "Valid JSON array"
echo '[1, 2, 3, "four", {"five": 5}]' > "$TEST_DIR/test2.json"
if json_validate "$TEST_DIR/test2.json"; then
  pass
else
  fail "validation to pass" "validation failed"
fi

# =============================================================================
# Test 3: Valid nested JSON
# =============================================================================
run_test "Valid nested JSON"
cat > "$TEST_DIR/test3.json" << 'EOF'
{
  "level1": {
    "level2": {
      "level3": {
        "value": "deep"
      }
    }
  },
  "array": [1, 2, 3]
}
EOF
if json_validate "$TEST_DIR/test3.json"; then
  pass
else
  fail "validation to pass" "validation failed"
fi

# =============================================================================
# Test 4: Invalid JSON - missing closing brace
# =============================================================================
run_test "Invalid JSON - missing closing brace"
echo '{"name": "test"' > "$TEST_DIR/test4.json"
if json_validate "$TEST_DIR/test4.json" 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 5: Invalid JSON - trailing comma
# =============================================================================
run_test "Invalid JSON - trailing comma"
echo '{"name": "test",}' > "$TEST_DIR/test5.json"
if json_validate "$TEST_DIR/test5.json" 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 6: Invalid JSON - unquoted key
# =============================================================================
run_test "Invalid JSON - unquoted key"
echo '{name: "test"}' > "$TEST_DIR/test6.json"
if json_validate "$TEST_DIR/test6.json" 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 7: Invalid JSON - single quotes
# =============================================================================
run_test "Invalid JSON - single quotes"
echo "{'name': 'test'}" > "$TEST_DIR/test7.json"
if json_validate "$TEST_DIR/test7.json" 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 8: Missing file returns error
# =============================================================================
run_test "Missing file returns error"
if json_validate "$TEST_DIR/nonexistent.json" 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 9: Missing argument returns error
# =============================================================================
run_test "Missing argument returns error"
if json_validate 2>/dev/null; then
  fail "validation to fail" "validation passed"
else
  pass
fi

# =============================================================================
# Test 10: Empty object is valid
# =============================================================================
run_test "Empty object is valid"
echo '{}' > "$TEST_DIR/test10.json"
if json_validate "$TEST_DIR/test10.json"; then
  pass
else
  fail "validation to pass" "validation failed"
fi

# =============================================================================
# Test 11: Empty array is valid
# =============================================================================
run_test "Empty array is valid"
echo '[]' > "$TEST_DIR/test11.json"
if json_validate "$TEST_DIR/test11.json"; then
  pass
else
  fail "validation to pass" "validation failed"
fi

# =============================================================================
# Test 12: Real-world schema file format
# =============================================================================
run_test "Real-world schema file format"
cat > "$TEST_DIR/test12.json" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "name": { "type": "string" },
    "version": { "type": "string" }
  },
  "required": ["name"]
}
EOF
if json_validate "$TEST_DIR/test12.json"; then
  pass
else
  fail "validation to pass" "validation failed"
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
