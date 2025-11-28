#!/bin/bash
# Manual Verification Tests for AI Context System v3.5.0
# Tests that actually execute commands to verify they work

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MANUAL VERIFICATION - Actual Command Execution          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  Note: These tests verify that commands can execute without"
echo "    errors. Full functionality testing requires Claude Code."
echo ""

# Test 1: Archive script dry-run execution
test_archive_script_execution() {
  echo "Test 1: Archive script dry-run execution"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 50 "context/SESSIONS.md"

  # Run archive script in dry-run mode
  if bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context --dry-run > /tmp/archive-output.txt 2>&1; then
    # Check output for expected messages
    if grep -q "DRY RUN" /tmp/archive-output.txt && grep -q "Would keep last 10 sessions" /tmp/archive-output.txt; then
      echo -e "\033[0;32m✓\033[0m Archive script dry-run successful"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m Archive output missing expected messages"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m Archive script failed to execute"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Cleanup
  rm -f /tmp/archive-output.txt
  cleanup_test_env
}

# Test 2: Archive script actual execution (small dataset)
test_archive_script_real_execution() {
  echo ""
  echo "Test 2: Archive script real execution (small dataset)"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 15 "context/SESSIONS.md"

  # Run archive script for real (but with small dataset)
  if bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context > /tmp/archive-real.txt 2>&1; then
    # Check that archive file was created
    ARCHIVE_FILE=$(ls context/SESSIONS-archive-*.md 2>/dev/null | head -1)

    if [ -n "$ARCHIVE_FILE" ] && [ -f "$ARCHIVE_FILE" ]; then
      echo -e "\033[0;32m✓\033[0m Archive file created: $(basename $ARCHIVE_FILE)"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))

      # Verify main file has 10 sessions (exclude Session Index)
      MAIN_COUNT=$(grep -cE "^## Session [0-9]+" context/SESSIONS.md 2>/dev/null || echo "0")

      if [ "$MAIN_COUNT" -eq 10 ]; then
        echo -e "\033[0;32m✓\033[0m Main file kept exactly 10 sessions"
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
      else
        echo -e "\033[0;31m✗\033[0m Main file has $MAIN_COUNT sessions (expected 10)"
        TESTS_RUN=$((TESTS_RUN + 1))
      fi

      # Verify backup was created
      if [ -f "context/SESSIONS.md.backup" ]; then
        echo -e "\033[0;32m✓\033[0m Backup file created"
        TESTS_RUN=$((TESTS_RUN + 1))
        TESTS_PASSED=$((TESTS_PASSED + 1))
      else
        echo -e "\033[0;31m✗\033[0m Backup file not created"
        TESTS_RUN=$((TESTS_RUN + 1))
      fi
    else
      echo -e "\033[0;31m✗\033[0m Archive file not created"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m Archive script failed"
    cat /tmp/archive-real.txt
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Cleanup
  rm -f /tmp/archive-real.txt
  cleanup_test_env
}

# Test 3: VERSION file is valid and parseable
test_version_file_validity() {
  echo ""
  echo "Test 3: VERSION file validity"

  if [ -f "$PROJECT_ROOT/VERSION" ]; then
    VERSION_CONTENT=$(cat "$PROJECT_ROOT/VERSION")

    # Check format (should be X.Y.Z)
    if echo "$VERSION_CONTENT" | grep -qE "^[0-9]+\.[0-9]+\.[0-9]+$"; then
      echo -e "\033[0;32m✓\033[0m VERSION file has valid format: $VERSION_CONTENT"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m VERSION file has invalid format: $VERSION_CONTENT"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m VERSION file not found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 4: Code review helpers script exists and is valid
test_code_review_helpers_validity() {
  echo ""
  echo "Test 4: Code review helpers script validity"

  if [ -f "$PROJECT_ROOT/scripts/code-review-helpers.sh" ]; then
    echo -e "\033[0;32m✓\033[0m code-review-helpers.sh exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Check it has no syntax errors
    if bash -n "$PROJECT_ROOT/scripts/code-review-helpers.sh" 2>/dev/null; then
      echo -e "\033[0;32m✓\033[0m code-review-helpers.sh has no syntax errors"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m code-review-helpers.sh has syntax errors"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m code-review-helpers.sh not found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 5: Common functions script exists and is valid
test_common_functions_validity() {
  echo ""
  echo "Test 5: Common functions script validity"

  if [ -f "$PROJECT_ROOT/scripts/common-functions.sh" ]; then
    echo -e "\033[0;32m✓\033[0m common-functions.sh exists"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))

    # Check it has no syntax errors
    if bash -n "$PROJECT_ROOT/scripts/common-functions.sh" 2>/dev/null; then
      echo -e "\033[0;32m✓\033[0m common-functions.sh has no syntax errors"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m common-functions.sh has syntax errors"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi

    # Check it can be sourced
    if bash -c "source '$PROJECT_ROOT/scripts/common-functions.sh'" 2>/dev/null; then
      echo -e "\033[0;32m✓\033[0m common-functions.sh can be sourced"
      TESTS_RUN=$((TESTS_RUN + 1))
      TESTS_PASSED=$((TESTS_PASSED + 1))
    else
      echo -e "\033[0;31m✗\033[0m common-functions.sh cannot be sourced"
      TESTS_RUN=$((TESTS_RUN + 1))
    fi
  else
    echo -e "\033[0;31m✗\033[0m common-functions.sh not found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Test 6: All command files are readable and have no obvious syntax errors
test_command_files_validity() {
  echo ""
  echo "Test 6: All command files validity"

  COMMAND_FILES=(
    "init-context.md"
    "update-context-system.md"
    "review-context.md"
    "save-full.md"
    "code-review.md"
  )

  INVALID_FILES=()

  for cmd_file in "${COMMAND_FILES[@]}"; do
    if [ ! -f "$PROJECT_ROOT/.claude/commands/$cmd_file" ]; then
      echo -e "\033[0;31m✗\033[0m Missing: $cmd_file"
      INVALID_FILES+=("$cmd_file")
    fi
  done

  if [ ${#INVALID_FILES[@]} -eq 0 ]; then
    echo -e "\033[0;32m✓\033[0m All command files present"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Missing ${#INVALID_FILES[@]} command files"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Run all manual verification tests
test_archive_script_execution
test_archive_script_real_execution
test_version_file_validity
test_code_review_helpers_validity
test_common_functions_validity
test_command_files_validity

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Note: Full command execution testing requires Claude Code."
echo "These tests verify scripts run without errors and produce"
echo "expected output. Actual workflow testing should be done"
echo "manually using Claude Code."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

print_test_summary
