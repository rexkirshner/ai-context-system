#!/bin/bash
# Test Phase 9.2: .context-local/ Customization Folder
# Version: See VERSION file at repository root
#
# Tests the .context-local/ folder convention that allows users
# to safely customize agents, commands, and templates without
# having their changes overwritten during upgrades.
#
# Test cases:
# 1. get_local_override_path() returns correct paths
# 2. Local agents override system agents
# 3. Local commands override system commands
# 4. Local templates override system templates
# 5. System files used when no local override exists
# 6. has_local_override() correctly detects overrides
# 7. list_local_overrides() returns all overrides
# 8. Documentation in .context-local/ is created on init

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_context_local_test_env() {
  TEST_DIR=$(mktemp -d -t acs-context-local-test.XXXXXX)
  mkdir -p "$TEST_DIR/.claude/agents"
  mkdir -p "$TEST_DIR/.claude/commands"
  mkdir -p "$TEST_DIR/.claude/templates"
}

cleanup_context_local_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Test 1: get_local_override_path() returns correct paths
# =============================================================================
test_local_override_path() {
  echo "Test 1: get_local_override_path() should return correct paths"

  setup_context_local_test_env

  # Test agent path
  local agent_path
  agent_path=$(get_local_override_path ".claude/agents/security-reviewer.md" "$TEST_DIR")
  local expected_agent="$TEST_DIR/.context-local/agents/security-reviewer.md"
  assert_equal "$agent_path" "$expected_agent" "Agent override path should be correct"

  # Test command path
  local cmd_path
  cmd_path=$(get_local_override_path ".claude/commands/build-check.md" "$TEST_DIR")
  local expected_cmd="$TEST_DIR/.context-local/commands/build-check.md"
  assert_equal "$cmd_path" "$expected_cmd" "Command override path should be correct"

  # Test template path
  local tmpl_path
  tmpl_path=$(get_local_override_path "templates/STATUS.template.md" "$TEST_DIR")
  local expected_tmpl="$TEST_DIR/.context-local/templates/STATUS.template.md"
  assert_equal "$tmpl_path" "$expected_tmpl" "Template override path should be correct"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 2: Local agents override system agents
# =============================================================================
test_agent_override() {
  echo ""
  echo "Test 2: Local agents should override system agents"

  setup_context_local_test_env

  # Create system agent
  echo "# System Security Reviewer" > "$TEST_DIR/.claude/agents/security-reviewer.md"

  # Create local override
  mkdir -p "$TEST_DIR/.context-local/agents"
  echo "# Custom Security Reviewer - Modified!" > "$TEST_DIR/.context-local/agents/security-reviewer.md"

  # Get effective file
  local effective
  effective=$(get_effective_file ".claude/agents/security-reviewer.md" "$TEST_DIR")

  # Should return local override
  assert_equal "$effective" "$TEST_DIR/.context-local/agents/security-reviewer.md" "Should use local agent override"

  # Check content is from local file
  local content
  content=$(cat "$effective")
  assert_contains "$content" "Modified" "Content should be from local override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 3: Local commands override system commands
# =============================================================================
test_command_override() {
  echo ""
  echo "Test 3: Local commands should override system commands"

  setup_context_local_test_env

  # Create system command
  echo "# System Build Check" > "$TEST_DIR/.claude/commands/build-check.md"

  # Create local override
  mkdir -p "$TEST_DIR/.context-local/commands"
  echo "# Custom Build Check - Enhanced!" > "$TEST_DIR/.context-local/commands/build-check.md"

  # Get effective file
  local effective
  effective=$(get_effective_file ".claude/commands/build-check.md" "$TEST_DIR")

  # Should return local override
  assert_equal "$effective" "$TEST_DIR/.context-local/commands/build-check.md" "Should use local command override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 4: Local templates override system templates
# =============================================================================
test_template_override() {
  echo ""
  echo "Test 4: Local templates should override system templates"

  setup_context_local_test_env

  # Create system template
  mkdir -p "$TEST_DIR/templates"
  echo "# System STATUS Template" > "$TEST_DIR/templates/STATUS.template.md"

  # Create local override
  mkdir -p "$TEST_DIR/.context-local/templates"
  echo "# Custom STATUS Template - Our Style!" > "$TEST_DIR/.context-local/templates/STATUS.template.md"

  # Get effective file
  local effective
  effective=$(get_effective_file "templates/STATUS.template.md" "$TEST_DIR")

  # Should return local override
  assert_equal "$effective" "$TEST_DIR/.context-local/templates/STATUS.template.md" "Should use local template override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 5: System files used when no local override exists
# =============================================================================
test_no_override_uses_system() {
  echo ""
  echo "Test 5: System files should be used when no local override exists"

  setup_context_local_test_env

  # Create system agent (no local override)
  echo "# System Agent" > "$TEST_DIR/.claude/agents/test-agent.md"

  # Get effective file
  local effective
  effective=$(get_effective_file ".claude/agents/test-agent.md" "$TEST_DIR")

  # Should return system file
  assert_equal "$effective" "$TEST_DIR/.claude/agents/test-agent.md" "Should use system file when no override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 6: has_local_override() correctly detects overrides
# =============================================================================
test_has_local_override() {
  echo ""
  echo "Test 6: has_local_override() should correctly detect overrides"

  setup_context_local_test_env

  # Create system agents
  echo "# Agent 1" > "$TEST_DIR/.claude/agents/agent1.md"
  echo "# Agent 2" > "$TEST_DIR/.claude/agents/agent2.md"

  # Create local override for agent1 only
  mkdir -p "$TEST_DIR/.context-local/agents"
  echo "# Custom Agent 1" > "$TEST_DIR/.context-local/agents/agent1.md"

  # Check agent1 (has override)
  local has_override1
  has_override1=$(has_local_override ".claude/agents/agent1.md" "$TEST_DIR")
  assert_equal "$has_override1" "true" "agent1.md should have local override"

  # Check agent2 (no override)
  local has_override2
  has_override2=$(has_local_override ".claude/agents/agent2.md" "$TEST_DIR")
  assert_equal "$has_override2" "false" "agent2.md should not have local override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 7: list_local_overrides() returns all overrides
# =============================================================================
test_list_local_overrides() {
  echo ""
  echo "Test 7: list_local_overrides() should return all overrides"

  setup_context_local_test_env

  # Create local overrides
  mkdir -p "$TEST_DIR/.context-local/agents"
  mkdir -p "$TEST_DIR/.context-local/commands"
  echo "# Agent" > "$TEST_DIR/.context-local/agents/custom-agent.md"
  echo "# Command" > "$TEST_DIR/.context-local/commands/custom-cmd.md"

  # List overrides
  local overrides
  overrides=$(list_local_overrides "$TEST_DIR")

  # Check that both are listed
  assert_contains "$overrides" "custom-agent.md" "Should list agent override"
  assert_contains "$overrides" "custom-cmd.md" "Should list command override"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 8: init_context_local() creates the directory structure
# =============================================================================
test_init_context_local() {
  echo ""
  echo "Test 8: init_context_local() should create directory structure"

  setup_context_local_test_env

  # Initialize .context-local
  init_context_local "$TEST_DIR"

  # Check directories exist
  assert_directory_exists "$TEST_DIR/.context-local" ".context-local directory"
  assert_directory_exists "$TEST_DIR/.context-local/agents" "agents subdirectory"
  assert_directory_exists "$TEST_DIR/.context-local/commands" "commands subdirectory"
  assert_directory_exists "$TEST_DIR/.context-local/templates" "templates subdirectory"

  # Check README exists
  assert_file_exists "$TEST_DIR/.context-local/README.md" "README.md"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 9: Context-local files are ignored by install manifest
# =============================================================================
test_context_local_not_in_manifest() {
  echo ""
  echo "Test 9: .context-local files should not be in install manifest"

  setup_context_local_test_env

  # Create system file
  echo "# System" > "$TEST_DIR/.claude/agents/test.md"

  # Create context-local file
  mkdir -p "$TEST_DIR/.context-local/agents"
  echo "# Custom" > "$TEST_DIR/.context-local/agents/custom.md"

  # Record installation
  record_install "$TEST_DIR" "5.1.0"

  # Check manifest
  local manifest="$TEST_DIR/.claude/.install-manifest.json"
  local has_context_local
  has_context_local=$(jq -r '.files[] | select(.path | contains(".context-local")) | .path' "$manifest" 2>/dev/null | wc -l | tr -d ' ')

  assert_equal "$has_context_local" "0" "Manifest should not contain .context-local files"

  cleanup_context_local_test_env
}

# =============================================================================
# Test 10: Local config overrides system config
# =============================================================================
test_config_override() {
  echo ""
  echo "Test 10: Local config should override system config values"

  setup_context_local_test_env

  # Create system config (using acs-settings.json as of v5.1.2)
  echo '{"theme": "light", "feature": "default"}' > "$TEST_DIR/.claude/acs-settings.json"

  # Create local config override
  mkdir -p "$TEST_DIR/.context-local"
  echo '{"theme": "dark"}' > "$TEST_DIR/.context-local/config.local.json"

  # Get merged config
  local merged
  merged=$(get_merged_config "$TEST_DIR")

  # Check that local value overrides
  local theme
  theme=$(echo "$merged" | jq -r '.theme')
  assert_equal "$theme" "dark" "Local config should override system theme"

  # Check that non-overridden value is preserved
  local feature
  feature=$(echo "$merged" | jq -r '.feature')
  assert_equal "$feature" "default" "Non-overridden values should be preserved"

  cleanup_context_local_test_env
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 9.2: .context-local/ Customization Tests           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

test_local_override_path
test_agent_override
test_command_override
test_template_override
test_no_override_uses_system
test_has_local_override
test_list_local_overrides
test_init_context_local
test_context_local_not_in_manifest
test_config_override

print_test_summary
