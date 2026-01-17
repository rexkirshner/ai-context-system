#!/bin/bash
# Test scanner monorepo integration
# Phase 6.1 of v5.1.0 implementation
#
# Tests the get_monorepo_context() function that provides monorepo
# information for the codebase scanner agent.
#
# Test cases:
# 1. Turborepo fixture → detects 3 workspaces
# 2. Nx fixture → detects workspaces
# 3. pnpm fixture → parses correctly
# 4. Single project → isMonorepo: false
# 5. Mixed indicators → priority order respected
# 6. Workspace dependencies extraction

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
# Test 1: Turborepo fixture detection
# =============================================================================
test_turborepo_fixture() {
  echo "Test 1: Should detect Turborepo monorepo and its workspaces"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-turborepo")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true"

  # Should be turborepo type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "turborepo" "monorepoType should be turborepo"

  # Should have 3 workspaces
  local workspace_count
  workspace_count=$(echo "$result" | jq -r '.workspaces | length')
  assert_equal "$workspace_count" "3" "Should have 3 workspaces"

  # Should have web workspace
  local has_web
  has_web=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("web")) | .path')
  assert_contains "$has_web" "web" "Should have web workspace"
}

# =============================================================================
# Test 2: Nx fixture detection
# =============================================================================
test_nx_fixture() {
  echo ""
  echo "Test 2: Should detect Nx monorepo and its workspaces"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-nx")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true for Nx"

  # Should be nx type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "nx" "monorepoType should be nx"

  # Should have workspaces (web, api, shared)
  local workspace_count
  workspace_count=$(echo "$result" | jq -r '.workspaces | length')
  assert_equal "$workspace_count" "3" "Nx should have 3 workspaces"
}

# =============================================================================
# Test 3: pnpm fixture detection
# =============================================================================
test_pnpm_fixture() {
  echo ""
  echo "Test 3: Should detect pnpm monorepo"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-pnpm")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true for pnpm"

  # Should be pnpm type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "pnpm" "monorepoType should be pnpm"
}

# =============================================================================
# Test 4: Single project detection
# =============================================================================
test_single_project() {
  echo ""
  echo "Test 4: Should detect single project (not monorepo)"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/single-project")

  # Should NOT be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "false" "isMonorepo should be false"

  # Should be single type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "single" "monorepoType should be single"

  # Should have no workspaces
  local workspace_count
  workspace_count=$(echo "$result" | jq -r '.workspaces | length')
  assert_equal "$workspace_count" "0" "Single project should have 0 workspaces"
}

# =============================================================================
# Test 5: Yarn workspaces detection
# =============================================================================
test_yarn_fixture() {
  echo ""
  echo "Test 5: Should detect Yarn workspaces monorepo"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-yarn")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true for Yarn"

  # Should be yarn type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "yarn" "monorepoType should be yarn"
}

# =============================================================================
# Test 6: Workspace type detection
# =============================================================================
test_workspace_type_detection() {
  echo ""
  echo "Test 6: Should detect workspace types (app, library)"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-nx")

  # Web should be an application (has next.js)
  local web_type
  web_type=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("web")) | .type // "unknown"')
  assert_contains "$web_type" "next" "Web workspace should be detected as Next.js app"

  # API should be an application
  local api_type
  api_type=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("api")) | .type // "unknown"')
  # API has express, so should detect that
  assert_not_equal "$api_type" "" "API workspace should have a type"

  # Shared should be a library
  local shared_type
  shared_type=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("shared")) | .type // "unknown"')
  assert_equal "$shared_type" "library" "Shared workspace should be library type"
}

# =============================================================================
# Test 7: Dependencies by workspace
# =============================================================================
test_dependencies_by_workspace() {
  echo ""
  echo "Test 7: Should extract dependencies by workspace"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-nx")

  # Should have byWorkspace section
  local has_by_workspace
  has_by_workspace=$(echo "$result" | jq -r '.dependencies.byWorkspace | keys | length')
  assert_greater_than "$has_by_workspace" "0" "Should have workspace dependencies"

  # Web workspace should have react dependency
  local web_deps
  web_deps=$(echo "$result" | jq -r '.workspaces[] | select(.name | contains("web")) | .dependencies | join(",")')
  assert_contains "$web_deps" "react" "Web workspace should have react dependency"
}

# =============================================================================
# Test 8: Build commands in output
# =============================================================================
test_build_commands() {
  echo ""
  echo "Test 8: Should include build commands"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-turborepo")

  # Should have buildCmd
  local build_cmd
  build_cmd=$(echo "$result" | jq -r '.buildCmd // "none"')
  assert_contains "$build_cmd" "turbo" "Turborepo should have turbo build command"

  # Should have workspaceCmd
  local workspace_cmd
  workspace_cmd=$(echo "$result" | jq -r '.workspaceCmd // "none"')
  assert_contains "$workspace_cmd" "filter" "Turborepo should have filter command for workspaces"
}

# =============================================================================
# Test 9: Lerna detection
# =============================================================================
test_lerna_fixture() {
  echo ""
  echo "Test 9: Should detect Lerna monorepo"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-lerna")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true for Lerna"

  # Should be lerna type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "lerna" "monorepoType should be lerna"
}

# =============================================================================
# Test 10: npm workspaces detection
# =============================================================================
test_npm_fixture() {
  echo ""
  echo "Test 10: Should detect npm workspaces monorepo"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-npm")

  # Should be a monorepo
  local is_monorepo
  is_monorepo=$(echo "$result" | jq -r '.isMonorepo')
  assert_equal "$is_monorepo" "true" "isMonorepo should be true for npm workspaces"

  # Should be npm type
  local mono_type
  mono_type=$(echo "$result" | jq -r '.monorepoType')
  assert_equal "$mono_type" "npm" "monorepoType should be npm"
}

# =============================================================================
# Test 11: Invalid directory handling
# =============================================================================
test_invalid_directory() {
  echo ""
  echo "Test 11: Should handle non-existent directory gracefully"

  local result
  result=$(get_monorepo_context "/nonexistent/path" 2>&1) || true

  # Should return valid JSON (with isMonorepo: false or error)
  local is_valid_json
  is_valid_json=$(echo "$result" | jq -r '.isMonorepo // "error"' 2>/dev/null || echo "invalid")
  # Either returns false or handles error
  assert_not_equal "$is_valid_json" "invalid" "Should return valid JSON or handle error"
}

# =============================================================================
# Test 12: Output schema compliance
# =============================================================================
test_schema_compliance() {
  echo ""
  echo "Test 12: Output should match expected schema"

  local result
  result=$(get_monorepo_context "$FIXTURES_DIR/monorepo-nx")

  # Must have isMonorepo
  local has_is_monorepo
  has_is_monorepo=$(echo "$result" | jq 'has("isMonorepo")')
  assert_equal "$has_is_monorepo" "true" "Must have isMonorepo field"

  # Must have monorepoType
  local has_type
  has_type=$(echo "$result" | jq 'has("monorepoType")')
  assert_equal "$has_type" "true" "Must have monorepoType field"

  # Must have workspaces array
  local workspaces_is_array
  workspaces_is_array=$(echo "$result" | jq '.workspaces | type')
  assert_equal "$workspaces_is_array" '"array"' "workspaces must be an array"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 6.1: Scanner Monorepo Integration Tests             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_turborepo_fixture
test_nx_fixture
test_pnpm_fixture
test_single_project
test_yarn_fixture
test_workspace_type_detection
test_dependencies_by_workspace
test_build_commands
test_lerna_fixture
test_npm_fixture
test_invalid_directory
test_schema_compliance

print_test_summary
