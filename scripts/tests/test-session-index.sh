#!/bin/bash
# Test session index generation
# Phase 1.2 of v5.1.0 implementation
#
# Test cases:
# 1. Generate index from sessions
# 2. Handle empty SESSIONS.md
# 3. Handle missing index section
# 4. Preserve content before/after index
# 5. Update existing index
# 6. Handle pipe-delimited format
# 7. Handle legacy dash format
# 8. Extract phase name correctly
# 9. Extract status correctly

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_test_env() {
  TEST_DIR=$(mktemp -d -t acs-session-index-test.XXXXXX)
  mkdir -p "$TEST_DIR/context"
}

cleanup_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Test 1: Generate index from sessions
# =============================================================================
test_generate_index() {
  echo "Test 1: Should generate index from sessions"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 | 2026-01-10 | Setup Phase

**Duration:** 1h | **Focus:** Initial setup | **Status:** ✅ Complete

Content here...

---

## Session 2 | 2026-01-12 | Development

**Duration:** 2h | **Focus:** Core features | **Status:** ✅ Complete

More content...

---

## Session 3 | 2026-01-14 | Testing

**Duration:** 1.5h | **Focus:** Test suite | **Status:** ⏳ In Progress

Testing content...

---
EOF

  local result
  result=$(generate_session_index "$TEST_DIR/context/SESSIONS.md")

  # Should succeed
  local success
  success=$([ $? -eq 0 ] && echo "yes" || echo "no")
  assert_equal "$success" "yes" "Should succeed"

  # Index should have 3 entries
  local index_entries
  index_entries=$(grep -cE "^\| [0-9]+ \|" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$index_entries" "3" "Should have 3 index entries"

  cleanup_test_env
}

# =============================================================================
# Test 2: Handle empty SESSIONS.md (no sessions)
# =============================================================================
test_no_sessions() {
  echo ""
  echo "Test 2: Should handle SESSIONS.md with no sessions"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---
EOF

  local result
  result=$(generate_session_index "$TEST_DIR/context/SESSIONS.md" 2>&1)

  # Should succeed (empty is valid)
  local success
  success=$([ $? -eq 0 ] && echo "yes" || echo "no")
  assert_equal "$success" "yes" "Should succeed with no sessions"

  # Index should be empty (no data rows)
  local index_entries
  index_entries=$(grep -cE "^\| [0-9]+ \|" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$index_entries" "0" "Should have 0 index entries"

  cleanup_test_env
}

# =============================================================================
# Test 3: Handle missing index section
# =============================================================================
test_missing_index_section() {
  echo ""
  echo "Test 3: Should add index section if missing"

  setup_test_env

  # SESSIONS.md without index section
  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session 1 | 2026-01-10 | Setup

**Duration:** 1h | **Focus:** Setup | **Status:** ✅ Complete

Content...

---
EOF

  local result
  result=$(generate_session_index "$TEST_DIR/context/SESSIONS.md" 2>&1)

  # Should succeed
  local success
  success=$([ $? -eq 0 ] && echo "yes" || echo "no")
  assert_equal "$success" "yes" "Should succeed and add index"

  # Index section should now exist
  local has_index
  has_index=$(grep -c "## Session Index" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_index" "1" "Should have Session Index heading"

  cleanup_test_env
}

# =============================================================================
# Test 4: Preserve content
# =============================================================================
test_preserve_content() {
  echo ""
  echo "Test 4: Should preserve session content"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

**Important header text to preserve**

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 | 2026-01-10 | Setup

**Duration:** 1h | **Focus:** Setup | **Status:** ✅ Complete

This specific content must be preserved word for word.

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Check content is preserved
  local has_content
  has_content=$(grep -c "This specific content must be preserved" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_content" "1" "Session content should be preserved"

  # Check header text is preserved
  local has_header
  has_header=$(grep -c "Important header text to preserve" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$has_header" "1" "Header text should be preserved"

  cleanup_test_env
}

# =============================================================================
# Test 5: Update existing index
# =============================================================================
test_update_existing_index() {
  echo ""
  echo "Test 5: Should update existing stale index"

  setup_test_env

  # Index is stale (only shows session 1, but session 2 exists)
  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|
| 1 | 2026-01-10 | Setup | Initial | ✅ |

---

## Session 1 | 2026-01-10 | Setup

Content...

---

## Session 2 | 2026-01-12 | Development

Content...

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Index should now have 2 entries
  local index_entries
  index_entries=$(grep -cE "^\| [0-9]+ \|" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$index_entries" "2" "Should have 2 index entries after update"

  cleanup_test_env
}

# =============================================================================
# Test 6: Handle pipe-delimited format
# =============================================================================
test_pipe_format() {
  echo ""
  echo "Test 6: Should parse pipe-delimited session headers"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 | 2026-01-10 | Phase Alpha

**Duration:** 1h | **Focus:** Setup work | **Status:** ✅ Complete

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Should extract phase name - check index rows contain the phase
  local has_phase
  has_phase=$(grep -E "^\| 1 \|.*Phase Alpha" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
  local phase_in_index
  phase_in_index=$([ "$has_phase" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$phase_in_index" "yes" "Phase name should be in index"

  cleanup_test_env
}

# =============================================================================
# Test 7: Handle legacy dash format
# =============================================================================
test_legacy_format() {
  echo ""
  echo "Test 7: Should parse legacy dash-delimited headers"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 - 2026-01-10

**Duration:** 1h | **Focus:** Legacy format | **Status:** ✅ Complete

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Should have parsed the session
  local index_entries
  index_entries=$(grep -cE "^\| [0-9]+ \|" "$TEST_DIR/context/SESSIONS.md" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  assert_equal "$index_entries" "1" "Should parse legacy format"

  cleanup_test_env
}

# =============================================================================
# Test 8: Extract status correctly
# =============================================================================
test_extract_status() {
  echo ""
  echo "Test 8: Should extract status from session"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 | 2026-01-10 | Setup

**Duration:** 1h | **Focus:** Initial | **Status:** ✅ Complete

---

## Session 2 | 2026-01-12 | Dev

**Duration:** 2h | **Focus:** Work | **Status:** ⏳ In Progress

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Should have complete status for session 1
  local complete_status
  complete_status=$(grep -E "^\| 1 \|" "$TEST_DIR/context/SESSIONS.md" | grep -c "✅" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local has_complete
  has_complete=$([ "$complete_status" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$has_complete" "yes" "Session 1 should show complete status"

  # Should have in-progress status for session 2
  local progress_status
  progress_status=$(grep -E "^\| 2 \|" "$TEST_DIR/context/SESSIONS.md" | grep -c "⏳" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local has_progress
  has_progress=$([ "$progress_status" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$has_progress" "yes" "Session 2 should show in-progress status"

  cleanup_test_env
}

# =============================================================================
# Test 9: Handle missing file
# =============================================================================
test_missing_file() {
  echo ""
  echo "Test 9: Should handle missing file"

  setup_test_env

  local exit_code
  generate_session_index "$TEST_DIR/context/NONEXISTENT.md" 2>/dev/null || exit_code=$?

  local failed_properly
  failed_properly=$([ "${exit_code:-0}" -ne 0 ] && echo "yes" || echo "no")
  assert_equal "$failed_properly" "yes" "Should fail for missing file"

  cleanup_test_env
}

# =============================================================================
# Test 10: Extract focus from status line
# =============================================================================
test_extract_focus() {
  echo ""
  echo "Test 10: Should extract focus from status line"

  setup_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Session History

---

## Session Index

| # | Date | Phase | Focus | Status |
|---|------|-------|-------|--------|

---

## Session 1 | 2026-01-10 | Setup

**Duration:** 1h | **Focus:** Building the authentication system | **Status:** ✅ Complete

---
EOF

  generate_session_index "$TEST_DIR/context/SESSIONS.md"

  # Should have focus in index (truncated if long)
  local has_focus
  has_focus=$(grep -E "^\| 1 \|" "$TEST_DIR/context/SESSIONS.md" | grep -c "auth" 2>/dev/null | head -1 | tr -d ' ' || echo "0")
  local focus_present
  focus_present=$([ "$has_focus" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$focus_present" "yes" "Focus should be in index"

  cleanup_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 1.2: Session Index Generation Tests                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_generate_index
test_no_sessions
test_missing_index_section
test_preserve_content
test_update_existing_index
test_pipe_format
test_legacy_format
test_extract_status
test_missing_file
test_extract_focus

print_test_summary
