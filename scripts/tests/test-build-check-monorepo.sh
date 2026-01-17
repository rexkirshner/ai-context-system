#!/bin/bash
# Test build-check monorepo workspace support
# Phase 6.2 of v5.1.0 implementation
#
# Tests the get_build_context() function that provides workspace-aware
# build commands for the /build-check command.
#
# Test cases:
# 1. Root context → runs root command
# 2. Workspace context → runs workspace command
# 3. --workspace flag → filters correctly
# 4. --all flag → runs root command regardless of context
# 5. --list flag → outputs workspace list without building
# 6. Single project → standard npm/yarn build

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
# Test 1: Root context detection
# =============================================================================
test_root_context() {
  echo "Test 1: Should detect monorepo root context"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-turborepo")

  # Should detect turborepo type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "turborepo" "Should detect turborepo"

  # Should have root build command
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "turbo" "Root should use turbo build"

  # Context should be root
  local context
  context=$(echo "$result" | jq -r '.context')
  assert_equal "$context" "root" "Context should be root"
}

# =============================================================================
# Test 2: Nx monorepo context
# =============================================================================
test_nx_context() {
  echo ""
  echo "Test 2: Should detect Nx monorepo context"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-nx")

  # Should detect nx type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "nx" "Should detect nx"

  # Should have nx build command
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "nx" "Root should use nx build"
}

# =============================================================================
# Test 3: Single project context
# =============================================================================
test_single_project_context() {
  echo ""
  echo "Test 3: Should handle single project (not monorepo)"

  local result
  result=$(get_build_context "$FIXTURES_DIR/single-project")

  # Should be single type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "single" "Should be single project"

  # Should have npm build command
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "npm run build" "Single project should use npm run build"
}

# =============================================================================
# Test 4: Workspace-specific build command
# =============================================================================
test_workspace_build_cmd() {
  echo ""
  echo "Test 4: Should generate workspace-specific build command"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-turborepo" "web")

  # Should have workspace-specific command
  local ws_cmd
  ws_cmd=$(echo "$result" | jq -r '.effectiveCmd')
  assert_contains "$ws_cmd" "filter" "Workspace command should use filter"
  assert_contains "$ws_cmd" "web" "Workspace command should include workspace name"
}

# =============================================================================
# Test 5: pnpm workspace command
# =============================================================================
test_pnpm_workspace_cmd() {
  echo ""
  echo "Test 5: Should generate pnpm workspace command"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-pnpm")

  # Should have pnpm root command
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')
  assert_contains "$build_cmd" "pnpm" "Should use pnpm build"

  # Workspace command should use --filter
  local ws_cmd
  ws_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  assert_contains "$ws_cmd" "filter" "pnpm workspace command should use --filter"
}

# =============================================================================
# Test 6: yarn workspace command
# =============================================================================
test_yarn_workspace_cmd() {
  echo ""
  echo "Test 6: Should generate yarn workspace command"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-yarn")

  # Should be yarn type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "yarn" "Should detect yarn"

  # Workspace command should use workspace
  local ws_cmd
  ws_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  assert_contains "$ws_cmd" "workspace" "yarn workspace command should use workspace"
}

# =============================================================================
# Test 7: List workspaces output
# =============================================================================
test_list_workspaces_output() {
  echo ""
  echo "Test 7: Should provide workspace list"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-turborepo")

  # Should have workspaces list
  local ws_count
  ws_count=$(echo "$result" | jq -r '.workspaces | length')
  assert_equal "$ws_count" "3" "Should have 3 workspaces in list"

  # Each workspace should have name and path
  local has_web
  has_web=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("web")) | .name')
  assert_contains "$has_web" "web" "Should include web workspace"
}

# =============================================================================
# Test 8: All flag behavior (simulate)
# =============================================================================
test_all_flag_behavior() {
  echo ""
  echo "Test 8: --all flag should use root command"

  # When --all is passed, should use buildCmd not effectiveCmd
  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-turborepo" "all")

  # effectiveCmd with "all" should be root command
  local eff_cmd
  eff_cmd=$(echo "$result" | jq -r '.effectiveCmd')
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd')

  assert_equal "$eff_cmd" "$build_cmd" "--all should use root build command"
}

# =============================================================================
# Test 9: Invalid workspace name handling
# =============================================================================
test_invalid_workspace() {
  echo ""
  echo "Test 9: Should handle invalid workspace name"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-turborepo" "nonexistent" 2>&1) || true

  # Should indicate workspace not found or use graceful fallback
  local has_error
  has_error=$(echo "$result" | jq -r '.error // "none"')
  # Either has an error field or falls back gracefully
  if [ "$has_error" != "none" ]; then
    assert_contains "$has_error" "not found" "Should indicate workspace not found"
  else
    # Falls back to running for the workspace name provided
    local eff_cmd
    eff_cmd=$(echo "$result" | jq -r '.effectiveCmd')
    assert_contains "$eff_cmd" "nonexistent" "Should attempt to build nonexistent workspace"
  fi
}

# =============================================================================
# Test 10: lerna workspace command
# =============================================================================
test_lerna_workspace_cmd() {
  echo ""
  echo "Test 10: Should generate lerna workspace command"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-lerna")

  # Should be lerna type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "lerna" "Should detect lerna"

  # Workspace command should use --scope
  local ws_cmd
  ws_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  assert_contains "$ws_cmd" "scope" "lerna workspace command should use --scope"
}

# =============================================================================
# Test 11: npm workspaces command
# =============================================================================
test_npm_workspace_cmd() {
  echo ""
  echo "Test 11: Should generate npm workspace command"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-npm")

  # Should be npm type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "npm" "Should detect npm"

  # Workspace command should use -w
  local ws_cmd
  ws_cmd=$(echo "$result" | jq -r '.workspaceCmd')
  # Use different pattern because "-w" is interpreted as grep flag
  local has_w_flag
  has_w_flag=$(echo "$ws_cmd" | grep -cF " -w" || echo "0")
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ "$has_w_flag" -gt 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} npm workspace command should use -w"
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} npm workspace command should use -w"
    echo "  Workspace cmd: $ws_cmd"
  fi
}

# =============================================================================
# Test 12: Output schema compliance
# =============================================================================
test_schema_compliance() {
  echo ""
  echo "Test 12: Output should match expected schema"

  local result
  result=$(get_build_context "$FIXTURES_DIR/monorepo-nx")

  # Must have monorepoType
  local has_type
  has_type=$(echo "$result" | jq 'has("monorepoType")')
  assert_equal "$has_type" "true" "Must have monorepoType field"

  # Must have buildCmd
  local has_build
  has_build=$(echo "$result" | jq 'has("buildCmd")')
  assert_equal "$has_build" "true" "Must have buildCmd field"

  # Must have workspaceCmd (can be null)
  local has_ws_cmd
  has_ws_cmd=$(echo "$result" | jq 'has("workspaceCmd")')
  assert_equal "$has_ws_cmd" "true" "Must have workspaceCmd field"

  # Must have context
  local has_context
  has_context=$(echo "$result" | jq 'has("context")')
  assert_equal "$has_context" "true" "Must have context field"

  # Must have effectiveCmd
  local has_eff
  has_eff=$(echo "$result" | jq 'has("effectiveCmd")')
  assert_equal "$has_eff" "true" "Must have effectiveCmd field"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 6.2: Build Check Monorepo Tests                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_root_context
test_nx_context
test_single_project_context
test_workspace_build_cmd
test_pnpm_workspace_cmd
test_yarn_workspace_cmd
test_list_workspaces_output
test_all_flag_behavior
test_invalid_workspace
test_lerna_workspace_cmd
test_npm_workspace_cmd
test_schema_compliance

print_test_summary
