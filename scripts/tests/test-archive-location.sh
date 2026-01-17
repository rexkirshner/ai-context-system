#!/bin/bash
# Test archive sessions location change
# Phase 3.2 of v5.1.0 implementation
#
# Tests that archived sessions go to .sessions-archive/ subdirectory
# instead of cluttering the main context/ directory.
#
# Test cases:
# 1. Archives created in .sessions-archive/ subdirectory
# 2. Archive filename includes session range
# 3. Directory created if it doesn't exist
# 4. Multiple archives handled correctly
# 5. Backward compatibility with existing archives

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test fixtures directory
TEST_DIR=""

setup_archive_test_env() {
  TEST_DIR=$(mktemp -d -t acs-archive-location-test.XXXXXX)
  mkdir -p "$TEST_DIR/context"
}

cleanup_archive_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# Helper to create SESSIONS.md with N sessions
create_test_sessions() {
  local count=$1
  local sessions_file="$TEST_DIR/context/SESSIONS.md"

  cat > "$sessions_file" << 'EOF'
# Sessions

## Session Index

| # | Date | Focus |
|---|------|-------|

---
EOF

  for i in $(seq 1 "$count"); do
    cat >> "$sessions_file" << EOF

## Session $i | 2026-01-$(printf "%02d" $((i % 28 + 1))) | Session $i

**Duration:** 1h | **Focus:** Work $i | **Status:** ✅ Complete

### Accomplishments
- Did work in session $i

---
EOF
  done
}

# =============================================================================
# Test 1: Archive directory is created
# =============================================================================
test_archive_directory_created() {
  echo "Test 1: Should create .sessions-archive/ directory"

  setup_archive_test_env

  # Create 15 sessions (archive 5, keep 10)
  create_test_sessions 15

  # Run archive script
  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check if .sessions-archive directory was created
  local archive_dir="$TEST_DIR/context/.sessions-archive"
  assert_directory_exists "$archive_dir" ".sessions-archive directory should be created"

  cleanup_archive_test_env
}

# =============================================================================
# Test 2: Archive file placed in subdirectory
# =============================================================================
test_archive_in_subdirectory() {
  echo ""
  echo "Test 2: Archive file should be in .sessions-archive/"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check for archive files in subdirectory
  local archive_count
  archive_count=$(find "$TEST_DIR/context/.sessions-archive" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

  local has_archive
  has_archive=$([ "$archive_count" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$has_archive" "yes" "Archive file should exist in .sessions-archive/"

  cleanup_archive_test_env
}

# =============================================================================
# Test 3: No archive files in main context/
# =============================================================================
test_no_archives_in_main_dir() {
  echo ""
  echo "Test 3: No archive files should be in main context/ directory"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check for SESSIONS-archive-* files in main context/
  local main_archive_count
  main_archive_count=$(find "$TEST_DIR/context" -maxdepth 1 -name "SESSIONS-archive-*.md" 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$main_archive_count" "0" "No archive files should be in main context/ directory"

  cleanup_archive_test_env
}

# =============================================================================
# Test 4: Archive filename includes session range
# =============================================================================
test_archive_filename_format() {
  echo ""
  echo "Test 4: Archive filename should include session range"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check archive filename format (should include session range or timestamp)
  local archive_files
  archive_files=$(ls "$TEST_DIR/context/.sessions-archive/"*.md 2>/dev/null | head -1)

  local has_identifier
  has_identifier="no"
  if [ -n "$archive_files" ]; then
    # Should have either timestamp or session range in name
    if echo "$archive_files" | grep -qE "(sessions-|[0-9]{4}-[0-9]{2}-[0-9]{2})"; then
      has_identifier="yes"
    fi
  fi

  assert_equal "$has_identifier" "yes" "Archive filename should have identifier"

  cleanup_archive_test_env
}

# =============================================================================
# Test 5: Multiple archives work correctly
# =============================================================================
test_multiple_archives() {
  echo ""
  echo "Test 5: Multiple archive operations should create multiple files"

  setup_archive_test_env

  # First archive: Create 15, keep 10 (archive 5)
  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Add more sessions
  for i in $(seq 16 25); do
    cat >> "$TEST_DIR/context/SESSIONS.md" << EOF

## Session $i | 2026-01-15 | Session $i

Content for session $i

---
EOF
  done

  # Second archive: Now 20 sessions, keep 10 (archive 10)
  sleep 1  # Ensure different timestamp
  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check for multiple archive files
  local archive_count
  archive_count=$(find "$TEST_DIR/context/.sessions-archive" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

  local has_multiple
  has_multiple=$([ "$archive_count" -ge 2 ] && echo "yes" || echo "no")
  assert_equal "$has_multiple" "yes" "Should have multiple archive files (found $archive_count)"

  cleanup_archive_test_env
}

# =============================================================================
# Test 6: Archive content is preserved
# =============================================================================
test_archive_content_preserved() {
  echo ""
  echo "Test 6: Archived session content should be preserved"

  setup_archive_test_env

  # Create sessions with identifiable content
  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

---

## Session 1 | 2026-01-01 | First Session

UNIQUE_MARKER_SESSION_1_CONTENT

---

## Session 2 | 2026-01-02 | Second Session

UNIQUE_MARKER_SESSION_2_CONTENT

---

## Session 3 | 2026-01-03 | Third Session

UNIQUE_MARKER_SESSION_3_CONTENT

---
EOF

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 1 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Check if archived content is preserved
  local archive_content
  archive_content=$(cat "$TEST_DIR/context/.sessions-archive/"*.md 2>/dev/null)

  assert_contains "$archive_content" "UNIQUE_MARKER_SESSION_1" "Session 1 content should be preserved"
  assert_contains "$archive_content" "UNIQUE_MARKER_SESSION_2" "Session 2 content should be preserved"

  cleanup_archive_test_env
}

# =============================================================================
# Test 7: Main SESSIONS.md only contains kept sessions
# =============================================================================
test_main_file_trimmed() {
  echo ""
  echo "Test 7: Main SESSIONS.md should only have kept sessions"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Count sessions in main file
  local session_count
  session_count=$(grep -cE "^## Session [0-9]+" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null || echo "0")

  assert_equal "$session_count" "10" "Main file should have exactly 10 sessions"

  cleanup_archive_test_env
}

# =============================================================================
# Test 8: Dry run doesn't create directory
# =============================================================================
test_dry_run_no_directory() {
  echo ""
  echo "Test 8: Dry run should not create .sessions-archive/"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --dry-run 2>&1 >/dev/null

  # Check that .sessions-archive was NOT created
  local archive_dir="$TEST_DIR/context/.sessions-archive"
  local no_dir
  no_dir=$([ ! -d "$archive_dir" ] && echo "yes" || echo "no")

  assert_equal "$no_dir" "yes" "Dry run should not create archive directory"

  cleanup_archive_test_env
}

# =============================================================================
# Test 9: Context directory only has expected files
# =============================================================================
test_context_dir_clean() {
  echo ""
  echo "Test 9: Context directory should be clean after archiving"

  setup_archive_test_env

  create_test_sessions 15

  "$PROJECT_ROOT/scripts/archive-sessions-helper.sh" \
    --keep 10 \
    --context "$TEST_DIR/context" \
    --force 2>&1 >/dev/null

  # Count .md files in main context/ (excluding subdirectories)
  local md_count
  md_count=$(find "$TEST_DIR/context" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

  # Should only have SESSIONS.md (and maybe backup)
  local is_clean
  is_clean=$([ "$md_count" -le 2 ] && echo "yes" || echo "no")

  assert_equal "$is_clean" "yes" "Context directory should have ≤2 .md files (found $md_count)"

  cleanup_archive_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 3.2: Archive Sessions Location Tests                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_archive_directory_created
test_archive_in_subdirectory
test_no_archives_in_main_dir
test_archive_filename_format
test_multiple_archives
test_archive_content_preserved
test_main_file_trimmed
test_dry_run_no_directory
test_context_dir_clean

print_test_summary
