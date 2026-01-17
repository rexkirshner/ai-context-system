#!/bin/bash
# Test quick context mode utilities
# Phase 3.1 of v5.1.0 implementation
#
# Tests the get_quick_context() function that provides minimal
# context loading for the /review-context --quick mode.
#
# Test cases:
# 1. Quick context returns minimal data
# 2. Extracts STATUS.md Quick Reference section only
# 3. Extracts last session from SESSIONS.md only
# 4. Works with missing optional files
# 5. Handles empty files gracefully
# 6. Performance: completes quickly even for large files

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_quick_test_env() {
  TEST_DIR=$(mktemp -d -t acs-quick-context-test.XXXXXX)
  mkdir -p "$TEST_DIR/context"
}

cleanup_quick_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Test 1: Quick context returns expected structure
# =============================================================================
test_quick_context_structure() {
  echo "Test 1: Quick context should return expected structure"

  setup_quick_test_env

  # Create minimal STATUS.md with Quick Reference
  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

**Last Updated:** 2026-01-16

## Quick Reference

| Field | Value |
|-------|-------|
| Project | Test Project |
| Phase | Development |
| Status | Active |

## Active Tasks

### In Progress
- [ ] Task 1: Implement feature X
- [ ] Task 2: Fix bug Y

### Completed
- [x] Task 0: Setup project

## Notes

Some detailed notes here...
EOF

  # Create SESSIONS.md with multiple sessions
  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

## Session Index

| # | Date | Focus |
|---|------|-------|
| 1 | 2026-01-14 | Initial setup |
| 2 | 2026-01-15 | Feature work |
| 3 | 2026-01-16 | Current work |

---

## Session 1 | 2026-01-14 | Setup

Old session content...

---

## Session 2 | 2026-01-15 | Feature

More old content...

---

## Session 3 | 2026-01-16 | Current

**Duration:** 2h | **Focus:** Current work | **Status:** ⏳ In Progress

### TL;DR
Working on feature X.

### Accomplishments
- Started feature X
- Fixed bug Y

### WIP State
- File: src/feature.ts:42
- Next: Add validation
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  # Should have quickReference
  local has_quick_ref
  has_quick_ref=$(echo "$result" | jq 'has("quickReference")')
  assert_equal "$has_quick_ref" "true" "Should have quickReference field"

  # Should have lastSession
  local has_last_session
  has_last_session=$(echo "$result" | jq 'has("lastSession")')
  assert_equal "$has_last_session" "true" "Should have lastSession field"

  # Should have activeTasks
  local has_active_tasks
  has_active_tasks=$(echo "$result" | jq 'has("activeTasks")')
  assert_equal "$has_active_tasks" "true" "Should have activeTasks field"

  cleanup_quick_test_env
}

# =============================================================================
# Test 2: Extracts Quick Reference section correctly
# =============================================================================
test_quick_reference_extraction() {
  echo ""
  echo "Test 2: Should extract Quick Reference section only"

  setup_quick_test_env

  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

**Last Updated:** 2026-01-16

## Quick Reference

| Field | Value |
|-------|-------|
| Project | My Test Project |
| Phase | Beta |
| Status | Active |

## Active Tasks

Long task list that should NOT be in quick reference...
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  # Quick reference should contain project name
  local quick_ref
  quick_ref=$(echo "$result" | jq -r '.quickReference')
  assert_contains "$quick_ref" "My Test Project" "Quick reference should contain project name"

  # Quick reference should contain phase
  assert_contains "$quick_ref" "Beta" "Quick reference should contain phase"

  # Quick reference should NOT contain detailed task list
  local has_long_tasks
  has_long_tasks=$(echo "$quick_ref" | grep -cF "Long task list" 2>/dev/null || true)
  has_long_tasks=${has_long_tasks:-0}
  has_long_tasks=$(echo "$has_long_tasks" | tr -d '[:space:]')
  assert_equal "$has_long_tasks" "0" "Quick reference should not contain detailed tasks"

  cleanup_quick_test_env
}

# =============================================================================
# Test 3: Extracts last session only
# =============================================================================
test_last_session_extraction() {
  echo ""
  echo "Test 3: Should extract only the last session"

  setup_quick_test_env

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

---

## Session 1 | 2026-01-10 | Old

Old session that should NOT appear.

---

## Session 2 | 2026-01-12 | Older

Another old session.

---

## Session 3 | 2026-01-16 | Current

**TL;DR:** This is the current session.

Working on important feature.
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  local last_session
  last_session=$(echo "$result" | jq -r '.lastSession')

  # Should contain Session 3
  assert_contains "$last_session" "Session 3" "Should contain last session number"
  assert_contains "$last_session" "Current" "Should contain last session focus"
  assert_contains "$last_session" "TL;DR" "Should contain TL;DR"

  # Should NOT contain Session 1
  local has_session_1
  has_session_1=$(echo "$last_session" | grep -cF "Session 1" 2>/dev/null || true)
  has_session_1=${has_session_1:-0}
  has_session_1=$(echo "$has_session_1" | tr -d '[:space:]')
  assert_equal "$has_session_1" "0" "Should not contain Session 1"

  cleanup_quick_test_env
}

# =============================================================================
# Test 4: Extracts active tasks
# =============================================================================
test_active_tasks_extraction() {
  echo ""
  echo "Test 4: Should extract active tasks"

  setup_quick_test_env

  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Quick Reference

Basic info here.

## Active Tasks

### In Progress
- [ ] Build authentication module
- [ ] Add unit tests

### Blocked
- [ ] Deploy to production (waiting for approval)

### Completed
- [x] Setup project
- [x] Initialize database
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  local active_tasks
  active_tasks=$(echo "$result" | jq -r '.activeTasks')

  # Should have in-progress tasks
  assert_contains "$active_tasks" "authentication" "Should contain in-progress tasks"

  # Should have blocked tasks
  assert_contains "$active_tasks" "Blocked" "Should indicate blocked tasks"

  cleanup_quick_test_env
}

# =============================================================================
# Test 5: Handles missing files gracefully
# =============================================================================
test_missing_files() {
  echo ""
  echo "Test 5: Should handle missing files gracefully"

  setup_quick_test_env

  # Create only STATUS.md, no SESSIONS.md
  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Quick Reference

| Project | Test |

## Active Tasks

- [ ] Task 1
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  # Should succeed
  local success
  success=$([ $? -eq 0 ] && echo "yes" || echo "no")
  assert_equal "$success" "yes" "Should succeed with missing files"

  # lastSession should indicate not found or be empty
  local last_session
  last_session=$(echo "$result" | jq -r '.lastSession')
  # Should be empty string or indicate no sessions
  local session_len
  session_len=$(echo "$last_session" | wc -c | tr -d ' ')
  # Either empty or contains "not found" message
  if [ "$session_len" -lt 5 ]; then
    assert_equal "1" "1" "lastSession is empty (acceptable)"
  else
    assert_contains "$last_session" "No sessions" "lastSession should indicate no sessions"
  fi

  cleanup_quick_test_env
}

# =============================================================================
# Test 6: Handles empty context directory
# =============================================================================
test_empty_context() {
  echo ""
  echo "Test 6: Should handle empty context directory"

  setup_quick_test_env

  # Don't create any files

  local result
  result=$(get_quick_context "$TEST_DIR/context" 2>&1) || true

  # Should return valid JSON even with empty context
  local is_valid_json
  is_valid_json=$(echo "$result" | jq -r 'type' 2>/dev/null || echo "invalid")
  assert_equal "$is_valid_json" "object" "Should return valid JSON object"

  cleanup_quick_test_env
}

# =============================================================================
# Test 7: Performance with large SESSIONS.md
# =============================================================================
test_large_sessions_performance() {
  echo ""
  echo "Test 7: Should be fast even with large SESSIONS.md"

  setup_quick_test_env

  # Create STATUS.md
  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Quick Reference

| Project | Test |

## Active Tasks

- [ ] Task 1
EOF

  # Create large SESSIONS.md (500+ sessions)
  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

---
EOF

  # Generate many sessions
  for i in $(seq 1 200); do
    cat >> "$TEST_DIR/context/SESSIONS.md" << EOF

## Session $i | 2026-01-01 | Session $i

**Duration:** 1h | **Focus:** Work $i | **Status:** ✅ Complete

### Accomplishments
- Did some work in session $i
- More work in session $i
- Even more work in session $i

### Notes
Some notes for session $i...

---
EOF
  done

  # Add the "current" session at the end
  cat >> "$TEST_DIR/context/SESSIONS.md" << 'EOF'

## Session 201 | 2026-01-16 | Current Session

**TL;DR:** This is the current session that should be extracted.

Working on the latest feature.
EOF

  # Time the quick context extraction
  local start_time
  start_time=$(date +%s)

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))

  # Should complete in under 5 seconds
  local is_fast
  is_fast=$([ "$duration" -lt 5 ] && echo "yes" || echo "no")
  assert_equal "$is_fast" "yes" "Should complete in under 5 seconds (took ${duration}s)"

  # Should still extract the last session
  local last_session
  last_session=$(echo "$result" | jq -r '.lastSession')
  assert_contains "$last_session" "Session 201" "Should extract last session from large file"

  cleanup_quick_test_env
}

# =============================================================================
# Test 8: Output format is suitable for AI consumption
# =============================================================================
test_output_format() {
  echo ""
  echo "Test 8: Output format should be AI-friendly"

  setup_quick_test_env

  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Project Status

## Quick Reference

| Field | Value |
|-------|-------|
| Project | AI Test |
| Phase | Development |

## Active Tasks

- [ ] Active task 1
EOF

  cat > "$TEST_DIR/context/SESSIONS.md" << 'EOF'
# Sessions

---

## Session 1 | 2026-01-16 | Current

**TL;DR:** Working on tests.
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  # Should be valid JSON
  local is_json
  is_json=$(echo "$result" | jq -r 'type' 2>/dev/null || echo "invalid")
  assert_equal "$is_json" "object" "Output should be valid JSON"

  # Should have summary field for AI
  local has_summary
  has_summary=$(echo "$result" | jq 'has("summary")')
  assert_equal "$has_summary" "true" "Should have summary field"

  # Summary should be concise
  local summary_len
  summary_len=$(echo "$result" | jq -r '.summary | length')
  local is_concise
  is_concise=$([ "$summary_len" -lt 500 ] && echo "yes" || echo "no")
  assert_equal "$is_concise" "yes" "Summary should be concise (<500 chars)"

  cleanup_quick_test_env
}

# =============================================================================
# Test 9: Respects context directory parameter
# =============================================================================
test_context_dir_parameter() {
  echo ""
  echo "Test 9: Should respect context directory parameter"

  setup_quick_test_env

  # Create a different context directory
  mkdir -p "$TEST_DIR/other-context"

  cat > "$TEST_DIR/other-context/STATUS.md" << 'EOF'
# Other Project Status

## Quick Reference

| Project | Other Project |

## Active Tasks

- [ ] Other task
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/other-context")

  local quick_ref
  quick_ref=$(echo "$result" | jq -r '.quickReference')
  assert_contains "$quick_ref" "Other Project" "Should read from specified context directory"

  cleanup_quick_test_env
}

# =============================================================================
# Test 10: Handles non-standard STATUS.md format
# =============================================================================
test_nonstandard_status_format() {
  echo ""
  echo "Test 10: Should handle non-standard STATUS.md format"

  setup_quick_test_env

  # STATUS.md without Quick Reference section
  cat > "$TEST_DIR/context/STATUS.md" << 'EOF'
# Status

**Project:** Legacy Project
**Phase:** Maintenance
**Status:** Stable

## Tasks

- Fix bugs
- Update docs
EOF

  local result
  result=$(get_quick_context "$TEST_DIR/context")

  # Should still return valid structure
  local is_valid
  is_valid=$(echo "$result" | jq -r 'type' 2>/dev/null || echo "invalid")
  assert_equal "$is_valid" "object" "Should return valid JSON for non-standard format"

  # Should extract what it can
  local quick_ref
  quick_ref=$(echo "$result" | jq -r '.quickReference')
  # Should have some content (either from Status header or fallback)
  local has_content
  has_content=$([ "${#quick_ref}" -gt 10 ] && echo "yes" || echo "no")
  assert_equal "$has_content" "yes" "Should extract available content"

  cleanup_quick_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 3.1: Quick Context Mode Tests                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_quick_context_structure
test_quick_reference_extraction
test_last_session_extraction
test_active_tasks_extraction
test_missing_files
test_empty_context
test_large_sessions_performance
test_output_format
test_context_dir_parameter
test_nonstandard_status_format

print_test_summary
