#!/bin/bash
# Test archive-decisions-helper.sh
# Phase 1.1 of v5.1.0 implementation
#
# Test cases:
# 1. Dry run produces preview without changes
# 2. Script handles file not found gracefully
# 3. Script handles empty file gracefully
# 4. No archiving when below threshold
# 5. Archives when above threshold
# 6. Keeps specified number of recent decisions
# 7. Creates backup before archiving
# 8. Archive file has correct format
# 9. Superseded decisions archived first
# 10. Decision Index is preserved
# 11. --force skips confirmation
# 12. Invalid --keep value rejected

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Test fixtures directory
TEST_DIR=""

setup_test_env() {
  TEST_DIR=$(mktemp -d -t acs-archive-decisions-test.XXXXXX)
  mkdir -p "$TEST_DIR/context"
}

cleanup_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# Create a mock DECISIONS.md with N decisions
create_mock_decisions() {
  local count="$1"
  local output_file="$2"
  local include_superseded="${3:-false}"

  cat > "$output_file" << 'HEADER'
# DECISIONS.md

**Decision log** - WHY choices were made.

---

## Decision Index

| ID | Date | Topic | Status |
|----|------|-------|--------|
HEADER

  # Add index entries
  for i in $(seq 1 "$count"); do
    local id=$(printf "D%03d" "$i")
    local status="Accepted"
    if [ "$include_superseded" = "true" ] && [ $((i % 5)) -eq 0 ]; then
      status="Superseded"
    fi
    echo "| $id | 2026-01-$((i % 28 + 1)) | Decision $i | $status |" >> "$output_file"
  done

  cat >> "$output_file" << 'MIDDLE'

---

MIDDLE

  # Add decision entries
  for i in $(seq 1 "$count"); do
    local id=$(printf "D%03d" "$i")
    local status="Accepted"
    if [ "$include_superseded" = "true" ] && [ $((i % 5)) -eq 0 ]; then
      status="Superseded"
    fi
    cat >> "$output_file" << EOF
## $id - Decision $i

**Date:** 2026-01-$((i % 28 + 1))
**Status:** $status

### Context
This is the context for decision $i.

### Decision
We decided to do thing $i.

---

EOF
  done
}

# =============================================================================
# Test 1: Dry run produces preview without changes
# =============================================================================
test_dry_run() {
  echo "Test 1: Dry run should preview without making changes"

  setup_test_env
  create_mock_decisions 20 "$TEST_DIR/context/DECISIONS.md"

  local original_md5
  original_md5=$(md5sum "$TEST_DIR/context/DECISIONS.md" | cut -d' ' -f1)

  local output
  output=$("$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --dry-run 2>&1)

  local new_md5
  new_md5=$(md5sum "$TEST_DIR/context/DECISIONS.md" | cut -d' ' -f1)

  # File should be unchanged
  assert_equal "$original_md5" "$new_md5" "File should be unchanged after dry run"

  # Output should mention dry run
  local has_dry_run
  has_dry_run=$(echo "$output" | grep -ci "dry" || echo "0")
  local mentions_dry_run
  mentions_dry_run=$([ "$has_dry_run" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$mentions_dry_run" "yes" "Output should mention dry run"

  cleanup_test_env
}

# =============================================================================
# Test 2: Script handles file not found gracefully
# =============================================================================
test_file_not_found() {
  echo ""
  echo "Test 2: Script should handle missing file gracefully"

  setup_test_env
  # Don't create the file

  local exit_code
  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --dry-run 2>&1 || exit_code=$?

  local failed_properly
  failed_properly=$([ "${exit_code:-0}" -ne 0 ] && echo "yes" || echo "no")
  assert_equal "$failed_properly" "yes" "Should exit with error for missing file"

  cleanup_test_env
}

# =============================================================================
# Test 3: No archiving when below threshold
# =============================================================================
test_below_threshold() {
  echo ""
  echo "Test 3: No archiving when below threshold"

  setup_test_env
  create_mock_decisions 5 "$TEST_DIR/context/DECISIONS.md"

  local output
  output=$("$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1)

  # Should indicate no archiving needed
  local no_archiving
  no_archiving=$(echo "$output" | grep -ci "no archiving" || echo "0")
  local indicated_no_archive
  indicated_no_archive=$([ "$no_archiving" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$indicated_no_archive" "yes" "Should indicate no archiving needed"

  # No archive file should be created
  local archive_count
  archive_count=$(find "$TEST_DIR/context" -name "DECISIONS-archive-*.md" 2>/dev/null | wc -l | tr -d ' ')
  assert_equal "$archive_count" "0" "No archive file should be created"

  cleanup_test_env
}

# =============================================================================
# Test 4: Archives when above threshold
# =============================================================================
test_archives_above_threshold() {
  echo ""
  echo "Test 4: Should archive when above threshold"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  # Archive file should be created
  local archive_count
  archive_count=$(find "$TEST_DIR/context" -name "DECISIONS-archive-*.md" 2>/dev/null | wc -l | tr -d ' ')
  assert_equal "$archive_count" "1" "Archive file should be created"

  cleanup_test_env
}

# =============================================================================
# Test 5: Keeps specified number of recent decisions
# =============================================================================
test_keeps_recent() {
  echo ""
  echo "Test 5: Should keep specified number of recent decisions"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  # Count remaining decisions in main file
  local remaining
  remaining=$(grep -cE "^## D[0-9]+ -" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$remaining" "10" "Should keep 10 recent decisions"

  cleanup_test_env
}

# =============================================================================
# Test 6: Creates backup before archiving
# =============================================================================
test_creates_backup() {
  echo ""
  echo "Test 6: Should create backup before archiving"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  # Backup file should exist
  local has_backup
  has_backup=$([ -f "$TEST_DIR/context/DECISIONS.md.backup" ] && echo "yes" || echo "no")
  assert_equal "$has_backup" "yes" "Backup file should be created"

  cleanup_test_env
}

# =============================================================================
# Test 7: Archive file has correct format
# =============================================================================
test_archive_format() {
  echo ""
  echo "Test 7: Archive file should have correct format"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  local archive_file
  archive_file=$(find "$TEST_DIR/context" -name "DECISIONS-archive-*.md" | head -1)

  # Should have header
  local has_header
  has_header=$(grep -c "Archived Decisions" "$archive_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local header_present
  header_present=$([ "$has_header" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$header_present" "yes" "Archive should have header"

  # Should have archived decisions
  local archived_count
  archived_count=$(grep -cE "^## D[0-9]+ -" "$archive_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$archived_count" "15" "Archive should contain 15 decisions"

  cleanup_test_env
}

# =============================================================================
# Test 8: Decision Index is updated
# =============================================================================
test_index_updated() {
  echo ""
  echo "Test 8: Decision Index should be updated after archiving"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  # Index should still exist
  local has_index
  has_index=$(grep -c "Decision Index" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local index_present
  index_present=$([ "$has_index" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$index_present" "yes" "Decision Index should be preserved"

  # Index should have correct number of entries (matching remaining decisions)
  local index_entries
  index_entries=$(grep -cE "^\| D[0-9]+" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$index_entries" "10" "Index should have 10 entries"

  cleanup_test_env
}

# =============================================================================
# Test 9: --no-backup skips backup creation
# =============================================================================
test_no_backup_option() {
  echo ""
  echo "Test 9: --no-backup should skip backup creation"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --no-backup \
    --force 2>&1

  # Backup file should NOT exist
  local has_backup
  has_backup=$([ -f "$TEST_DIR/context/DECISIONS.md.backup" ] && echo "yes" || echo "no")
  assert_equal "$has_backup" "no" "Backup file should NOT be created with --no-backup"

  cleanup_test_env
}

# =============================================================================
# Test 10: Invalid --keep value rejected
# =============================================================================
test_invalid_keep() {
  echo ""
  echo "Test 10: Invalid --keep value should be rejected"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  local exit_code
  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep "invalid" \
    --dry-run 2>&1 || exit_code=$?

  local failed_properly
  failed_properly=$([ "${exit_code:-0}" -ne 0 ] && echo "yes" || echo "no")
  assert_equal "$failed_properly" "yes" "Should reject invalid --keep value"

  cleanup_test_env
}

# =============================================================================
# Test 11: Archived decisions have correct IDs
# =============================================================================
test_archived_ids() {
  echo ""
  echo "Test 11: Archived decisions should be the oldest ones"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  local archive_file
  archive_file=$(find "$TEST_DIR/context" -name "DECISIONS-archive-*.md" | head -1)

  # Archive should contain D001 (oldest)
  local has_d001
  has_d001=$(grep -c "## D001 -" "$archive_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local d001_archived
  d001_archived=$([ "$has_d001" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$d001_archived" "yes" "D001 should be in archive"

  # Main file should NOT contain D001
  local main_has_d001
  main_has_d001=$(grep -c "## D001 -" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local d001_in_main
  d001_in_main=$([ "$main_has_d001" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$d001_in_main" "no" "D001 should NOT be in main file"

  # Main file should contain D025 (newest)
  local has_d025
  has_d025=$(grep -c "## D025 -" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local d025_in_main
  d025_in_main=$([ "$has_d025" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$d025_in_main" "yes" "D025 should be in main file"

  cleanup_test_env
}

# =============================================================================
# Test 12: Total decisions preserved (no data loss)
# =============================================================================
test_no_data_loss() {
  echo ""
  echo "Test 12: Total decisions should be preserved (no data loss)"

  setup_test_env
  create_mock_decisions 25 "$TEST_DIR/context/DECISIONS.md"

  "$PROJECT_ROOT/scripts/archive-decisions-helper.sh" \
    --context "$TEST_DIR/context" \
    --keep 10 \
    --force 2>&1

  local archive_file
  archive_file=$(find "$TEST_DIR/context" -name "DECISIONS-archive-*.md" | head -1)

  # Count decisions in main + archive
  local main_count
  main_count=$(grep -cE "^## D[0-9]+ -" "$TEST_DIR/context/DECISIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")

  local archive_count
  archive_count=$(grep -cE "^## D[0-9]+ -" "$archive_file" 2>/dev/null | head -1 | tr -d ' ' || echo "0")

  local total=$((main_count + archive_count))
  assert_equal "$total" "25" "Total decisions should be preserved"

  cleanup_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 1.1: Archive Decisions Tests                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_dry_run
test_file_not_found
test_below_threshold
test_archives_above_threshold
test_keeps_recent
test_creates_backup
test_archive_format
test_index_updated
test_no_backup_option
test_invalid_keep
test_archived_ids
test_no_data_loss

print_test_summary
