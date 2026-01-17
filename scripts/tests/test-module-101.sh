#!/bin/bash
# Test MODULE-101: SESSIONS.md Archiving Core Logic
# Issue: PERF-1 - Large SESSIONS.md files

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test 1: Basic archiving - 40 sessions, keep 10
test_basic_archiving() {
  echo "Test 1: Archive old sessions and keep recent ones"

  # Setup
  setup_test_env
  mkdir -p context

  # Create SESSIONS.md with 40 sessions
  create_test_sessions 40 "context/SESSIONS.md"

  # Run archiving script
  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null

  # Count sessions in main file (exclude "Session Index" header)
  MAIN_COUNT=$(grep -cE "^## Session [0-9]+" context/SESSIONS.md 2>/dev/null || echo "0")

  # Count sessions in archive (v5.1.0: now in .sessions-archive/ subdirectory)
  ARCHIVE_FILE=$(ls context/.sessions-archive/sessions-archive-*.md 2>/dev/null | head -1)
  if [ -n "$ARCHIVE_FILE" ]; then
    ARCHIVE_COUNT=$(grep -cE "^## Session [0-9]+" "$ARCHIVE_FILE" 2>/dev/null || echo "0")
  else
    ARCHIVE_COUNT=0
  fi

  # Total should equal 40
  TOTAL=$((MAIN_COUNT + ARCHIVE_COUNT))

  assert_equal "$MAIN_COUNT" "10" "Main file should have 10 sessions"
  assert_equal "$ARCHIVE_COUNT" "30" "Archive should have 30 old sessions"
  assert_equal "$TOTAL" "40" "No sessions should be lost"

  # Cleanup
  cleanup_test_env
}

# Test 2: Backup is created before modifying
test_backup_creation() {
  echo ""
  echo "Test 2: Backup should be created before modifying SESSIONS.md"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 20 "context/SESSIONS.md"

  # Run archiving
  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null

  # Check backup exists
  assert_file_exists "context/SESSIONS.md.backup" "Backup file"

  # Cleanup
  cleanup_test_env
}

# Test 3: Idempotency - running twice doesn't duplicate
test_idempotency() {
  echo ""
  echo "Test 3: Running archiving twice should be idempotent"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 30 "context/SESSIONS.md"

  # Run archiving twice
  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null
  FIRST_MAIN=$(grep -cE "^## Session [0-9]+" context/SESSIONS.md 2>/dev/null || echo "0")

  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null
  SECOND_MAIN=$(grep -cE "^## Session [0-9]+" context/SESSIONS.md 2>/dev/null || echo "0")

  assert_equal "$FIRST_MAIN" "$SECOND_MAIN" "Session count should remain the same"

  # Cleanup
  cleanup_test_env
}

# Test 4: Archive file naming (year-based)
test_archive_file_naming() {
  echo ""
  echo "Test 4: Archive files should be named with current year"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 25 "context/SESSIONS.md"

  # Run archiving
  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null

  # Check archive file exists with current year prefix (v5.1.0: now sessions-archive-YYYY-MM-DD-HHMMSS.md)
  YEAR=$(date +%Y)

  # Find any archive file with the current year (v5.1.0: now in .sessions-archive/ subdirectory)
  ARCHIVE_FILE=$(ls context/.sessions-archive/sessions-archive-${YEAR}*.md 2>/dev/null | head -1)

  if [ -n "$ARCHIVE_FILE" ] && [ -f "$ARCHIVE_FILE" ]; then
    echo -e "\033[0;32m✓\033[0m Archive file named correctly: $(basename "$ARCHIVE_FILE")"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Archive file not found matching sessions-archive-${YEAR}*.md"
    echo "   Found files: $(ls context/.sessions-archive/ 2>/dev/null || echo 'directory not found')"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Cleanup
  cleanup_test_env
}

# Test 5: Session index is preserved
test_session_index_preserved() {
  echo ""
  echo "Test 5: Session Index should be preserved in main file"

  # Setup
  setup_test_env
  mkdir -p context
  create_test_sessions 20 "context/SESSIONS.md"

  # Run archiving
  bash "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" --keep 10 --context context 2>/dev/null

  # Check that main file still has session index header
  if grep -q "^## Session Index" context/SESSIONS.md 2>/dev/null; then
    echo -e "\033[0;32m✓\033[0m Session Index preserved"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Session Index not found"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi

  # Cleanup
  cleanup_test_env
}

# Test 6: Script exists and is executable
test_script_exists() {
  echo ""
  echo "Test 6: archive-sessions-helper.sh should exist and be executable"

  assert_file_exists "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" "Archive script"

  if [ -x "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" ]; then
    echo -e "\033[0;32m✓\033[0m Script is executable"
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "\033[0;31m✗\033[0m Script is not executable"
    TESTS_RUN=$((TESTS_RUN + 1))
  fi
}

# Run all tests
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MODULE-101: SESSIONS.md Archiving Core Logic             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_script_exists
test_basic_archiving
test_backup_creation
test_idempotency
test_archive_file_naming
test_session_index_preserved

print_test_summary
