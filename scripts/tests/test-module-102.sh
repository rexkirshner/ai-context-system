#!/bin/bash
# Test MODULE-102: Auto-Trigger Archiving in /save-full
# Issue: PERF-1 - Automatic archiving trigger

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: save-full.md has archiving check
test_save_full_has_archiving_check() {
  echo "Test 1: save-full.md should have archiving check code"

  if grep -q "archive-sessions-helper\|SESSIONS\.md.*large\|wc -l.*SESSIONS" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    echo -e "\033[0;32m✓\033[0m save-full.md has archiving check"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m save-full.md missing archiving check"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 2: Archiving logic checks file size
test_archiving_checks_file_size() {
  echo ""
  echo "Test 2: Archiving logic should check SESSIONS.md file size"

  # Check for wc -l command on SESSIONS.md
  if grep -q "wc -l.*SESSIONS\.md" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    echo -e "\033[0;32m✓\033[0m File size check exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m File size check missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: Threshold is reasonable (should be >1000)
test_archiving_threshold() {
  echo ""
  echo "Test 3: Archiving threshold should be reasonable (>1000 lines)"

  # Look for the threshold value in the archiving check
  if grep -qE "SESSIONS_LINES.*-gt [0-9]+|LINE_COUNT.*-gt [0-9]+" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    # Extract the threshold value
    THRESHOLD=$(grep -oE "SESSIONS_LINES.*-gt [0-9]+|LINE_COUNT.*-gt [0-9]+" "$PROJECT_ROOT/.claude/commands/save-full.md" | grep -oE "[0-9]+" | head -1)

    if [ -n "$THRESHOLD" ] && [ "$THRESHOLD" -gt 1000 ]; then
      echo -e "\033[0;32m✓\033[0m Threshold is reasonable: $THRESHOLD"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m Threshold too low or not found: ${THRESHOLD:-unknown}"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m No threshold check found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: User is prompted (not automatic)
test_archiving_prompts_user() {
  echo ""
  echo "Test 4: Archiving should prompt user (not automatic)"

  # Check for read -p or user confirmation
  if grep -q "read -p.*[Aa]rchive\|Archive.*\[Y/n\]" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    echo -e "\033[0;32m✓\033[0m User prompt exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m User prompt missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Calls archive-sessions-helper.sh
test_calls_archive_script() {
  echo ""
  echo "Test 5: Should call archive-sessions-helper.sh script"

  if grep -q "archive-sessions-helper\.sh" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    echo -e "\033[0;32m✓\033[0m Calls archive-sessions-helper.sh"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Does not call archive-sessions-helper.sh"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: Integration - archiving script exists and works
test_archive_script_integration() {
  echo ""
  echo "Test 6: Integration - archive script should exist and be functional"

  # Test that the script exists and is executable
  if [ -x "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" ]; then
    echo -e "\033[0;32m✓\033[0m Archive script exists and is executable"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Archive script not found or not executable"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 7: Default keeps 10 sessions
test_default_keep_value() {
  echo ""
  echo "Test 7: Default should keep 10 recent sessions"

  # Check for --keep 10 in the command
  if grep -q "archive-sessions-helper\.sh.*--keep 10" "$PROJECT_ROOT/.claude/commands/save-full.md"; then
    echo -e "\033[0;32m✓\033[0m Default keeps 10 sessions"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Default keep value not 10 or missing"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-102: Auto-Trigger Archiving in /save-full         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_save_full_has_archiving_check
test_archiving_checks_file_size
test_archiving_threshold
test_archiving_prompts_user
test_calls_archive_script
test_archive_script_integration
test_default_keep_value

print_test_summary
