#!/bin/bash
# Test monorepo detection functions from common-functions.sh
# Phase 0.4 of v5.1.0 implementation
#
# Test cases:
# 1. Turborepo fixture → type: "turborepo"
# 2. Nx fixture → type: "nx"
# 3. Lerna fixture → type: "lerna"
# 4. pnpm fixture → type: "pnpm"
# 5. Yarn workspaces → type: "yarn"
# 6. npm workspaces → type: "npm"
# 7. Single project → type: "single"
# 8. Mixed indicators → follows priority order

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
FIXTURES_DIR="$PROJECT_ROOT/test/fixtures"

# =============================================================================
# Test 1: Turborepo detection
# =============================================================================
test_turborepo_detection() {
  echo "Test 1: Turborepo fixture should detect type 'turborepo'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-turborepo")

  # Validate JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Check type
  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "turborepo" "Type should be 'turborepo'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "turbo" "Build command should use turbo"
}

# =============================================================================
# Test 2: Nx detection
# =============================================================================
test_nx_detection() {
  echo ""
  echo "Test 2: Nx fixture should detect type 'nx'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-nx")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "nx" "Type should be 'nx'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "nx" "Build command should use nx"
}

# =============================================================================
# Test 3: Lerna detection
# =============================================================================
test_lerna_detection() {
  echo ""
  echo "Test 3: Lerna fixture should detect type 'lerna'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-lerna")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "lerna" "Type should be 'lerna'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "lerna" "Build command should use lerna"
}

# =============================================================================
# Test 4: pnpm workspaces detection
# =============================================================================
test_pnpm_detection() {
  echo ""
  echo "Test 4: pnpm fixture should detect type 'pnpm'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-pnpm")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "pnpm" "Type should be 'pnpm'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "pnpm" "Build command should use pnpm"
}

# =============================================================================
# Test 5: Yarn workspaces detection
# =============================================================================
test_yarn_detection() {
  echo ""
  echo "Test 5: Yarn fixture should detect type 'yarn'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-yarn")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "yarn" "Type should be 'yarn'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "yarn" "Build command should use yarn"
}

# =============================================================================
# Test 6: npm workspaces detection
# =============================================================================
test_npm_detection() {
  echo ""
  echo "Test 6: npm fixture should detect type 'npm'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-npm")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "npm" "Type should be 'npm'"

  # Check buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "npm" "Build command should use npm"
}

# =============================================================================
# Test 7: Single project detection
# =============================================================================
test_single_project_detection() {
  echo ""
  echo "Test 7: Single project fixture should detect type 'single'"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/single-project")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "single" "Type should be 'single'"

  # Check workspaceCmd is null
  local workspace_cmd
  workspace_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  assert_equal "$workspace_cmd" "null" "workspaceCmd should be null for single project"
}

# =============================================================================
# Test 8: Priority order (turborepo takes precedence over npm workspaces)
# =============================================================================
test_priority_order() {
  echo ""
  echo "Test 8: When multiple indicators exist, turborepo should take priority"

  # Turborepo fixture also has package.json with workspaces
  # Turborepo should win
  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-turborepo")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "turborepo" "Turborepo should take priority over npm workspaces"
}

# =============================================================================
# Test 9: Default directory is current directory
# =============================================================================
test_default_directory() {
  echo ""
  echo "Test 9: No argument should use current directory"

  # Run from project root (which doesn't have monorepo indicators)
  local result
  result=$(cd "$PROJECT_ROOT" && detect_monorepo)

  # Validate JSON
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON even from current directory"
}

# =============================================================================
# Test 10: Non-existent directory gracefully returns single
# =============================================================================
test_nonexistent_directory() {
  echo ""
  echo "Test 10: Non-existent directory should return type 'single'"

  local result
  result=$(detect_monorepo "/nonexistent/path/12345")

  local type
  type=$(echo "$result" | jq -r '.type')
  assert_equal "$type" "single" "Non-existent directory should return 'single'"
}

# =============================================================================
# Test 11: workspaceCmd is present for monorepos
# =============================================================================
test_workspace_cmd_present() {
  echo ""
  echo "Test 11: Monorepos should have workspaceCmd for filtering"

  local result
  result=$(detect_monorepo "$FIXTURES_DIR/monorepo-turborepo")

  local workspace_cmd
  workspace_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  assert_not_equal "$workspace_cmd" "null" "workspaceCmd should be present for monorepos"
  assert_contains "$workspace_cmd" "filter" "Turborepo workspaceCmd should contain 'filter'"
}

# =============================================================================
# Test 12: list_workspaces returns workspace array for monorepos
# =============================================================================
test_list_workspaces_monorepo() {
  echo ""
  echo "Test 12: list_workspaces should return workspaces for turborepo"

  local result
  result=$(list_workspaces "$FIXTURES_DIR/monorepo-turborepo")

  # Should be valid JSON array
  echo "$result" | jq . > /dev/null 2>&1
  assert_equal "$?" "0" "Output should be valid JSON"

  # Should have 3 workspaces (web, api, ui)
  local count
  count=$(echo "$result" | jq 'length')
  assert_equal "$count" "3" "Should find 3 workspaces"
}

# =============================================================================
# Test 13: list_workspaces returns workspace names
# =============================================================================
test_list_workspaces_names() {
  echo ""
  echo "Test 13: list_workspaces should include workspace names"

  local result
  result=$(list_workspaces "$FIXTURES_DIR/monorepo-turborepo")

  # Check that names are present
  local names
  names=$(echo "$result" | jq -r '.[].name' | sort | tr '\n' ',')
  assert_contains "$names" "@fixture/api" "Should contain @fixture/api"
  assert_contains "$names" "@fixture/web" "Should contain @fixture/web"
  assert_contains "$names" "@fixture/ui" "Should contain @fixture/ui"
}

# =============================================================================
# Test 14: list_workspaces returns workspace paths
# =============================================================================
test_list_workspaces_paths() {
  echo ""
  echo "Test 14: list_workspaces should include workspace paths"

  local result
  result=$(list_workspaces "$FIXTURES_DIR/monorepo-turborepo")

  # Check that paths are present
  local paths
  paths=$(echo "$result" | jq -r '.[].path' | sort | tr '\n' ',')
  assert_contains "$paths" "apps/api" "Should contain apps/api path"
  assert_contains "$paths" "apps/web" "Should contain apps/web path"
  assert_contains "$paths" "packages/ui" "Should contain packages/ui path"
}

# =============================================================================
# Test 15: list_workspaces returns empty for single project
# =============================================================================
test_list_workspaces_single() {
  echo ""
  echo "Test 15: list_workspaces should return empty array for single project"

  local result
  result=$(list_workspaces "$FIXTURES_DIR/single-project")

  assert_equal "$result" "[]" "Single project should have no workspaces"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 0.4: Monorepo Detection Tests                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_turborepo_detection
test_nx_detection
test_lerna_detection
test_pnpm_detection
test_yarn_detection
test_npm_detection
test_single_project_detection
test_priority_order
test_default_directory
test_nonexistent_directory
test_workspace_cmd_present
test_list_workspaces_monorepo
test_list_workspaces_names
test_list_workspaces_paths
test_list_workspaces_single

print_test_summary
