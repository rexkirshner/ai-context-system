#!/bin/bash
# Test dry-run mode for code review
# Phase 5.3 of v5.1.0 implementation
#
# Test cases:
# 1. Dry run produces output without errors
# 2. Output includes codebase analysis section
# 3. Output includes agent selection section
# 4. Decisions shown when DECISIONS.md exists
# 5. No DECISIONS.md → graceful skip of decisions section
# 6. No files created (audit directory unchanged)
# 7. Estimated scope is shown

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_OUTPUT_DIR=""

setup_dry_run_test_env() {
  TEST_OUTPUT_DIR=$(mktemp -d -t acs-dry-run-test.XXXXXX)
  mkdir -p "$TEST_OUTPUT_DIR/docs/audits"
  mkdir -p "$TEST_OUTPUT_DIR/context"
}

cleanup_dry_run_test_env() {
  if [ -n "$TEST_OUTPUT_DIR" ] && [ -d "$TEST_OUTPUT_DIR" ]; then
    rm -rf "$TEST_OUTPUT_DIR"
  fi
}

# =============================================================================
# Test 1: Dry run produces valid output
# =============================================================================
test_dry_run_produces_output() {
  echo "Test 1: Dry run should produce formatted output"

  setup_dry_run_test_env

  # Create mock codebase context
  local context='{
    "structure": {
      "projectType": "webapp",
      "hasUI": true,
      "hasTests": false,
      "hasDatabase": false,
      "frameworks": ["astro", "react"]
    },
    "files": {
      "hasTypeScript": true,
      "totalFiles": 57,
      "byExtension": {
        ".ts": 23,
        ".astro": 15,
        ".json": 10,
        ".md": 9
      }
    },
    "size": {
      "totalLines": 2400
    }
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should produce non-empty output
  local has_output
  has_output=$([ -n "$output" ] && echo "yes" || echo "no")
  assert_equal "$has_output" "yes" "Should produce output"

  # Should contain header
  assert_contains "$output" "Dry Run" "Should contain dry run header"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 2: Output includes codebase analysis
# =============================================================================
test_dry_run_codebase_analysis() {
  echo ""
  echo "Test 2: Dry run should include codebase analysis"

  setup_dry_run_test_env

  local context='{
    "structure": {
      "projectType": "webapp",
      "hasUI": true,
      "hasTests": true,
      "hasDatabase": false,
      "frameworks": ["next.js"]
    },
    "files": {
      "hasTypeScript": true,
      "totalFiles": 100,
      "byExtension": {".ts": 50, ".tsx": 30, ".json": 20}
    },
    "size": {"totalLines": 5000}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should show file counts
  assert_contains "$output" "100" "Should show total file count"

  # Should show frameworks
  assert_contains "$output" "next.js" "Should show detected frameworks"

  # Should show UI detection
  assert_contains "$output" "Has UI" "Should show UI detection"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 3: Output includes agent selection
# =============================================================================
test_dry_run_agent_selection() {
  echo ""
  echo "Test 3: Dry run should include agent selection"

  setup_dry_run_test_env

  local context='{
    "structure": {
      "projectType": "webapp",
      "hasUI": true,
      "hasTests": false,
      "hasDatabase": true,
      "frameworks": ["express"]
    },
    "files": {"hasTypeScript": false, "totalFiles": 30},
    "size": {"totalLines": 1000}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should mention agents
  assert_contains "$output" "Agent" "Should mention agents"

  # Should show security-reviewer (always selected)
  assert_contains "$output" "security" "Should show security reviewer"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 4: Decisions shown when DECISIONS.md exists
# =============================================================================
test_dry_run_with_decisions() {
  echo ""
  echo "Test 4: Dry run should show decisions when DECISIONS.md exists"

  setup_dry_run_test_env

  # Create DECISIONS.md using correct format (## D### - Title)
  cat > "$TEST_OUTPUT_DIR/context/DECISIONS.md" << 'EOF'
# Project Decisions

## D001 - No Test Framework

**Status:** Active
**Date:** 2026-01-01

Using manual testing for this project.

## D002 - Static Site Only

**Status:** Active
**Date:** 2026-01-01

No database needed for this static site.
EOF

  local context='{
    "structure": {"projectType": "webapp", "hasUI": true, "hasTests": false, "hasDatabase": false},
    "files": {"hasTypeScript": true, "totalFiles": 20},
    "size": {"totalLines": 500}
  }'

  local decisions_context
  decisions_context=$(load_decisions_context "$TEST_OUTPUT_DIR/context/DECISIONS.md")

  local output
  output=$(format_dry_run_output "$context" "$decisions_context" "$TEST_OUTPUT_DIR")

  # Should show decisions section
  assert_contains "$output" "Decision" "Should mention decisions"

  # Should show D001
  assert_contains "$output" "D001" "Should show D001 decision ID"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 5: No DECISIONS.md gracefully handled
# =============================================================================
test_dry_run_without_decisions() {
  echo ""
  echo "Test 5: Dry run should work without DECISIONS.md"

  setup_dry_run_test_env

  local context='{
    "structure": {"projectType": "webapp", "hasUI": true, "hasTests": true, "hasDatabase": false},
    "files": {"hasTypeScript": true, "totalFiles": 50},
    "size": {"totalLines": 2000}
  }'

  # No DECISIONS.md - empty decisions context
  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should still produce valid output
  local has_output
  has_output=$([ -n "$output" ] && echo "yes" || echo "no")
  assert_equal "$has_output" "yes" "Should produce output without DECISIONS.md"

  # Should have codebase section
  assert_contains "$output" "Codebase" "Should have codebase section"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 6: Estimated scope shown
# =============================================================================
test_dry_run_estimated_scope() {
  echo ""
  echo "Test 6: Dry run should show estimated scope"

  setup_dry_run_test_env

  local context='{
    "structure": {"projectType": "webapp", "hasUI": true, "hasTests": false, "hasDatabase": false},
    "files": {"hasTypeScript": true, "totalFiles": 57},
    "size": {"totalLines": 2400}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should show lines estimate
  assert_contains "$output" "2400" "Should show line count"
  assert_contains "$output" "57" "Should show file count"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 7: Agent selection reasons shown
# =============================================================================
test_dry_run_selection_reasons() {
  echo ""
  echo "Test 7: Dry run should show why agents are selected/skipped"

  setup_dry_run_test_env

  local context='{
    "structure": {
      "projectType": "webapp",
      "hasUI": false,
      "hasTests": true,
      "hasDatabase": false,
      "frameworks": ["express"]
    },
    "files": {"hasTypeScript": true, "totalFiles": 30},
    "size": {"totalLines": 1000}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should indicate selection reasons
  # At minimum, should show which are selected vs skipped
  local has_selection_info
  has_selection_info=$(echo "$output" | grep -c -E "(selected|skipped|✓|✗)" || echo "0")
  local shows_selection
  shows_selection=$([ "$has_selection_info" -gt 0 ] && echo "yes" || echo "no")
  assert_equal "$shows_selection" "yes" "Should show selection status for agents"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 8: Frameworks list shown
# =============================================================================
test_dry_run_frameworks() {
  echo ""
  echo "Test 8: Dry run should list detected frameworks"

  setup_dry_run_test_env

  local context='{
    "structure": {
      "projectType": "webapp",
      "hasUI": true,
      "hasTests": false,
      "hasDatabase": true,
      "frameworks": ["react", "express", "prisma"]
    },
    "files": {"hasTypeScript": true, "totalFiles": 80},
    "size": {"totalLines": 4000}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should show multiple frameworks
  assert_contains "$output" "react" "Should show react"
  assert_contains "$output" "express" "Should show express"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 9: File type breakdown shown
# =============================================================================
test_dry_run_file_types() {
  echo ""
  echo "Test 9: Dry run should show file type breakdown"

  setup_dry_run_test_env

  local context='{
    "structure": {"projectType": "webapp", "hasUI": true, "hasTests": false, "hasDatabase": false},
    "files": {
      "hasTypeScript": true,
      "totalFiles": 50,
      "byExtension": {
        ".ts": 20,
        ".tsx": 15,
        ".json": 10,
        ".md": 5
      }
    },
    "size": {"totalLines": 2000}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should show TypeScript count
  assert_contains "$output" "TypeScript" "Should mention TypeScript"

  cleanup_dry_run_test_env
}

# =============================================================================
# Test 10: Empty codebase handled
# =============================================================================
test_dry_run_empty_codebase() {
  echo ""
  echo "Test 10: Dry run should handle empty/minimal codebase"

  setup_dry_run_test_env

  local context='{
    "structure": {"projectType": "unknown", "hasUI": false, "hasTests": false, "hasDatabase": false},
    "files": {"hasTypeScript": false, "totalFiles": 0},
    "size": {"totalLines": 0}
  }'

  local output
  output=$(format_dry_run_output "$context" "" "$TEST_OUTPUT_DIR")

  # Should still produce valid output
  local has_output
  has_output=$([ -n "$output" ] && echo "yes" || echo "no")
  assert_equal "$has_output" "yes" "Should produce output for empty codebase"

  cleanup_dry_run_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 5.3: Dry-Run Mode Tests                             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_dry_run_produces_output
test_dry_run_codebase_analysis
test_dry_run_agent_selection
test_dry_run_with_decisions
test_dry_run_without_decisions
test_dry_run_estimated_scope
test_dry_run_selection_reasons
test_dry_run_frameworks
test_dry_run_file_types
test_dry_run_empty_codebase

print_test_summary
