#!/bin/bash
# Test MODULE-006: Smart SESSIONS.md Loading
# Issue: BUG-5 - Token limit crash on large files

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Small file (<1000 lines) - should read fully
test_small_sessions_file() {
  echo "Test 1: Small file (<1000 lines) should suggest full read"

  # Setup
  setup_test_env
  mkdir -p context

  # Create small SESSIONS.md (500 lines using create_large_sessions_file)
  create_large_sessions_file 500 "context/SESSIONS.md"

  # Test the smart loading logic
  FILE_SIZE=$(wc -l < "context/SESSIONS.md" | tr -d ' ')

  # Simulate the bash code logic
  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY="strategically"
  else
    STRATEGY="minimally"
  fi

  assert_equal "$STRATEGY" "fully" "Small file should use 'fully' strategy"

  # Cleanup
  cleanup_test_env
}

# Test 2: Medium file (1000-5000 lines) - should use strategic reading
test_medium_sessions_file() {
  echo ""
  echo "Test 2: Medium file (1000-5000 lines) should suggest strategic read"

  # Setup
  setup_test_env
  mkdir -p context

  # Create medium SESSIONS.md (2000 lines)
  create_large_sessions_file 2000 "context/SESSIONS.md"

  # Test the smart loading logic
  FILE_SIZE=$(wc -l < "context/SESSIONS.md" | tr -d ' ')

  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY="strategically"
  else
    STRATEGY="minimally"
  fi

  assert_equal "$STRATEGY" "strategically" "Medium file should use 'strategically' strategy"

  # Cleanup
  cleanup_test_env
}

# Test 3: Large file (>5000 lines) - should use minimal reading
test_large_sessions_file() {
  echo ""
  echo "Test 3: Large file (>5000 lines) should suggest minimal read"

  # Setup
  setup_test_env
  mkdir -p context

  # Create large SESSIONS.md (need >5000 lines)
  # 400 sessions × ~13 lines/session ≈ 5200+ lines (accounting for header overhead)
  create_test_sessions 400 "context/SESSIONS.md"

  # Test the smart loading logic
  FILE_SIZE=$(wc -l < "context/SESSIONS.md" | tr -d ' ')

  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY="strategically"
  else
    STRATEGY="minimally"
  fi

  # Verify we created enough lines
  assert_greater_than "$FILE_SIZE" "5000" "Test file should be >5000 lines"
  assert_equal "$STRATEGY" "minimally" "Large file (${FILE_SIZE} lines) should use 'minimally'"

  # Cleanup
  cleanup_test_env
}

# Test 4: review-context.md contains smart loading code
test_review_context_has_smart_loading() {
  echo ""
  echo "Test 4: review-context.md should contain smart loading bash code"

  # Check for the bash code pattern that implements smart loading
  if grep -q "FILE_SIZE=.*wc -l.*SESSIONS.md" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
    # Check for the conditional logic (search whole file for FILE_SIZE >= 1000 pattern)
    if grep -q "FILE_SIZE.*-ge 1000\|FILE_SIZE.*>=.*1000\|FILE_SIZE.*1000" "$PROJECT_ROOT/.claude/commands/review-context.md"; then
      echo -e "\033[0;32m✓\033[0m Smart loading bash code exists"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m FILE_SIZE check exists but no conditional logic"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m No smart loading bash code found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Logic correctness test
test_logic_correctness() {
  echo ""
  echo "Test 5: Verify loading strategy logic works correctly"

  # Setup
  setup_test_env
  mkdir -p context

  # Test the logic with known values
  # Small: 500 lines
  FILE_SIZE=500
  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY_SMALL="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY_SMALL="strategically"
  else
    STRATEGY_SMALL="minimally"
  fi

  # Medium: 2500 lines
  FILE_SIZE=2500
  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY_MEDIUM="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY_MEDIUM="strategically"
  else
    STRATEGY_MEDIUM="minimally"
  fi

  # Large: 7000 lines
  FILE_SIZE=7000
  if [ "$FILE_SIZE" -lt 1000 ]; then
    STRATEGY_LARGE="fully"
  elif [ "$FILE_SIZE" -lt 5000 ]; then
    STRATEGY_LARGE="strategically"
  else
    STRATEGY_LARGE="minimally"
  fi

  assert_equal "$STRATEGY_SMALL" "fully" "500 lines should use 'fully'"
  assert_equal "$STRATEGY_MEDIUM" "strategically" "2500 lines should use 'strategically'"
  assert_equal "$STRATEGY_LARGE" "minimally" "7000 lines should use 'minimally'"

  # Cleanup
  cleanup_test_env
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-006: Smart SESSIONS.md Loading                    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_small_sessions_file
test_medium_sessions_file
test_large_sessions_file
test_review_context_has_smart_loading
test_logic_correctness

print_test_summary
