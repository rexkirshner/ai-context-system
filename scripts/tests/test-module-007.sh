#!/bin/bash
# Test MODULE-007: Context Folder Auto-Detection
# Issue: BUG-6 - Commands fail from subdirectories

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: validate-context.md has context detection
test_validate_context_has_detection() {
  echo "Test 1: validate-context.md should have context folder detection"

  if grep -q "find-context-folder\|find_context_folder" .claude/commands/validate-context.md; then
    echo -e "\033[0;32m✓\033[0m validate-context.md has context detection"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m validate-context.md missing context detection"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 2: export-context.md has context detection
test_export_context_has_detection() {
  echo ""
  echo "Test 2: export-context.md should have context folder detection"

  if grep -q "find-context-folder\|find_context_folder" .claude/commands/export-context.md; then
    echo -e "\033[0;32m✓\033[0m export-context.md has context detection"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m export-context.md missing context detection"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 3: All 5 critical commands have detection
test_all_commands_have_detection() {
  echo ""
  echo "Test 3: All 5 commands should have context folder detection"

  COMMANDS_WITH_DETECTION=0

  for cmd in save.md save-full.md review-context.md validate-context.md export-context.md; do
    if grep -q "find-context-folder\|find_context_folder" .claude/commands/$cmd 2>/dev/null; then
      ((COMMANDS_WITH_DETECTION++))
    fi
  done

  assert_equal "$COMMANDS_WITH_DETECTION" "5" "All 5 commands should have context detection"
}

# Test 4: find-context-folder.sh script exists
test_find_context_folder_exists() {
  echo ""
  echo "Test 4: scripts/find-context-folder.sh should exist"

  assert_file_exists "scripts/find-context-folder.sh" "find-context-folder.sh script"
}

# Test 5: find-context-folder.sh is executable
test_find_context_folder_executable() {
  echo ""
  echo "Test 5: scripts/find-context-folder.sh should be executable"

  if [ -x "scripts/find-context-folder.sh" ]; then
    echo -e "\033[0;32m✓\033[0m find-context-folder.sh is executable"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m find-context-folder.sh is not executable"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: Commands use CONTEXT_DIR variable
test_commands_use_context_dir() {
  echo ""
  echo "Test 6: Commands should use \$CONTEXT_DIR variable"

  COMMANDS_USING_VAR=0

  for cmd in validate-context.md export-context.md; do
    if grep -qE '\$CONTEXT_DIR|$CONTEXT_DIR' .claude/commands/$cmd 2>/dev/null; then
      ((COMMANDS_USING_VAR++))
    fi
  done

  assert_greater_than "$COMMANDS_USING_VAR" "0" "At least some commands should use \$CONTEXT_DIR"
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-007: Context Folder Auto-Detection                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_validate_context_has_detection
test_export_context_has_detection
test_all_commands_have_detection
test_find_context_folder_exists
test_find_context_folder_executable
test_commands_use_context_dir

print_test_summary
