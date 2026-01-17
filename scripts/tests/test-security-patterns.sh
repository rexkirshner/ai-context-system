#!/bin/bash
# Test Phase 7.2: Security-Relevant Pattern Improvements
# Version: See VERSION file at repository root
#
# Tests the tiered security pattern detection system that reduces
# false positives while maintaining detection accuracy.
#
# Tier 1: High-confidence filename patterns (always flagged)
# Tier 2: Patterns with exclusions (flagged unless matches exclusion)
# Tier 3: Content-based confirmation (for ambiguous files)
#
# Test cases:
# 1-5:   Tier 1 patterns (auth, login, session, etc.)
# 6-10:  Tier 2 exclusions (keyboard, password_validator, etc.)
# 11-14: Tier 3 content-based detection
# 15-17: User configuration support
# 18-20: Edge cases

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source test helpers
source "$SCRIPT_DIR/test-helpers.sh"

# Source common functions
source "$PROJECT_ROOT/scripts/common-functions.sh"

# Test fixtures directory
TEST_DIR=""

setup_security_pattern_test_env() {
  TEST_DIR=$(mktemp -d -t acs-security-patterns-test.XXXXXX)
}

cleanup_security_pattern_test_env() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    rm -rf "$TEST_DIR"
  fi
}

# =============================================================================
# Tier 1 Tests: High-Confidence Patterns
# =============================================================================

test_tier1_auth_patterns() {
  echo "Test 1: Tier 1 - auth patterns should be flagged"

  setup_security_pattern_test_env

  # Create auth-related files
  touch "$TEST_DIR/auth.ts"
  touch "$TEST_DIR/authentication.js"
  touch "$TEST_DIR/authService.py"
  touch "$TEST_DIR/user-auth.go"

  local auth_result auth_service_result auth_full_result user_auth_result
  auth_result=$(is_security_relevant "auth.ts")
  auth_service_result=$(is_security_relevant "authService.py")
  auth_full_result=$(is_security_relevant "authentication.js")
  user_auth_result=$(is_security_relevant "user-auth.go")

  assert_equal "$auth_result" "true" "auth.ts should be flagged"
  assert_equal "$auth_service_result" "true" "authService.py should be flagged"
  assert_equal "$auth_full_result" "true" "authentication.js should be flagged"
  assert_equal "$user_auth_result" "true" "user-auth.go should be flagged"

  cleanup_security_pattern_test_env
}

test_tier1_login_patterns() {
  echo ""
  echo "Test 2: Tier 1 - login patterns should be flagged"

  local login_result login_page_result user_login_result
  login_result=$(is_security_relevant "login.tsx")
  login_page_result=$(is_security_relevant "LoginPage.tsx")
  user_login_result=$(is_security_relevant "user-login.js")

  assert_equal "$login_result" "true" "login.tsx should be flagged"
  assert_equal "$login_page_result" "true" "LoginPage.tsx should be flagged"
  assert_equal "$user_login_result" "true" "user-login.js should be flagged"
}

test_tier1_session_patterns() {
  echo ""
  echo "Test 3: Tier 1 - session patterns should be flagged"

  local session_result session_mgr_result
  session_result=$(is_security_relevant "session.ts")
  session_mgr_result=$(is_security_relevant "sessionManager.py")

  assert_equal "$session_result" "true" "session.ts should be flagged"
  assert_equal "$session_mgr_result" "true" "sessionManager.py should be flagged"
}

test_tier1_oauth_jwt_patterns() {
  echo ""
  echo "Test 4: Tier 1 - oauth/jwt patterns should be flagged"

  local oauth_result jwt_result
  oauth_result=$(is_security_relevant "oauth.ts")
  jwt_result=$(is_security_relevant "jwtUtils.js")

  assert_equal "$oauth_result" "true" "oauth.ts should be flagged"
  assert_equal "$jwt_result" "true" "jwtUtils.js should be flagged"
}

test_tier1_env_patterns() {
  echo ""
  echo "Test 5: Tier 1 - .env patterns should be flagged (not .env.example)"

  local env_result env_local_result env_example_result
  env_result=$(is_security_relevant ".env")
  env_local_result=$(is_security_relevant ".env.local")
  env_example_result=$(is_security_relevant ".env.example")

  assert_equal "$env_result" "true" ".env should be flagged"
  assert_equal "$env_local_result" "true" ".env.local should be flagged"
  assert_equal "$env_example_result" "false" ".env.example should NOT be flagged"
}

# =============================================================================
# Tier 2 Tests: Patterns with Exclusions
# =============================================================================

test_tier2_key_exclusions() {
  echo ""
  echo "Test 6: Tier 2 - key patterns should exclude keyboard/keydown/hotkey"

  local apikey_result keyboard_result keydown_result hotkey_result keyframe_result
  apikey_result=$(is_security_relevant "apiKey.ts")
  keyboard_result=$(is_security_relevant "keyboard.ts")
  keydown_result=$(is_security_relevant "keydown.js")
  hotkey_result=$(is_security_relevant "hotkey.tsx")
  keyframe_result=$(is_security_relevant "keyframe.css")

  assert_equal "$apikey_result" "true" "apiKey.ts should be flagged"
  assert_equal "$keyboard_result" "false" "keyboard.ts should NOT be flagged"
  assert_equal "$keydown_result" "false" "keydown.js should NOT be flagged"
  assert_equal "$hotkey_result" "false" "hotkey.tsx should NOT be flagged"
  assert_equal "$keyframe_result" "false" "keyframe.css should NOT be flagged"
}

test_tier2_password_exclusions() {
  echo ""
  echo "Test 7: Tier 2 - password patterns should exclude validators/policies"

  local password_result pwd_validator_result pwd_policy_result pwd_strength_result
  password_result=$(is_security_relevant "password.ts")
  pwd_validator_result=$(is_security_relevant "password_validator.ts")
  pwd_policy_result=$(is_security_relevant "passwordPolicy.js")
  pwd_strength_result=$(is_security_relevant "password-strength.tsx")

  assert_equal "$password_result" "true" "password.ts should be flagged"
  assert_equal "$pwd_validator_result" "false" "password_validator.ts should NOT be flagged"
  assert_equal "$pwd_policy_result" "false" "passwordPolicy.js should NOT be flagged"
  assert_equal "$pwd_strength_result" "false" "password-strength.tsx should NOT be flagged"
}

test_tier2_token_exclusions() {
  echo ""
  echo "Test 8: Tier 2 - token patterns should exclude tokenize/token_type"

  local token_result tokenize_result token_type_result
  token_result=$(is_security_relevant "token.ts")
  tokenize_result=$(is_security_relevant "tokenize.py")
  token_type_result=$(is_security_relevant "token_type.ts")

  assert_equal "$token_result" "true" "token.ts should be flagged"
  assert_equal "$tokenize_result" "false" "tokenize.py should NOT be flagged"
  assert_equal "$token_type_result" "false" "token_type.ts should NOT be flagged"
}

test_tier2_secret_exclusions() {
  echo ""
  echo "Test 9: Tier 2 - secret patterns should exclude test/spec files"

  local secret_result secret_test_result secret_spec_result secret_doc_result
  secret_result=$(is_security_relevant "secret.ts")
  secret_test_result=$(is_security_relevant "secret_test.go")
  secret_spec_result=$(is_security_relevant "secret.spec.ts")
  secret_doc_result=$(is_security_relevant "secrets.md")

  assert_equal "$secret_result" "true" "secret.ts should be flagged"
  assert_equal "$secret_test_result" "false" "secret_test.go should NOT be flagged"
  assert_equal "$secret_spec_result" "false" "secret.spec.ts should NOT be flagged"
  assert_equal "$secret_doc_result" "false" "secrets.md should NOT be flagged"
}

test_tier2_api_directory_handling() {
  echo ""
  echo "Test 10: Tier 2 - api in directory path should NOT flag the file"

  local api_file_result api_dir_result api_routes_result
  api_file_result=$(is_security_relevant "api.config.ts")
  api_dir_result=$(is_security_relevant "api/routes.ts")
  api_routes_result=$(is_security_relevant "src/api/handler.js")

  assert_equal "$api_file_result" "true" "api.config.ts should be flagged"
  assert_equal "$api_dir_result" "false" "api/routes.ts (in api dir) should NOT be flagged"
  assert_equal "$api_routes_result" "false" "src/api/handler.js (in api dir) should NOT be flagged"
}

# =============================================================================
# Tier 3 Tests: Content-Based Confirmation
# =============================================================================

test_tier3_content_hardcoded_secrets() {
  echo ""
  echo "Test 11: Tier 3 - files with hardcoded secrets should be flagged"

  setup_security_pattern_test_env

  # Create a config file with hardcoded API key
  # Note: Using sk_test_ prefix to avoid GitHub push protection while still testing detection
  cat > "$TEST_DIR/config.ts" << 'EOF'
export const config = {
  api_key: "sk_test_FAKE_TEST_KEY_00000000000000000",
  endpoint: "https://api.example.com"
};
EOF

  local result
  result=$(check_content_for_secrets "$TEST_DIR/config.ts")

  assert_equal "$result" "true" "File with hardcoded API key should be flagged"

  cleanup_security_pattern_test_env
}

test_tier3_content_password_assignment() {
  echo ""
  echo "Test 12: Tier 3 - files with password assignment should be flagged"

  setup_security_pattern_test_env

  # Create file with password assignment
  cat > "$TEST_DIR/db.py" << 'EOF'
import psycopg2

password = "supersecret123"
conn = psycopg2.connect(
    host="localhost",
    password=password
)
EOF

  local result
  result=$(check_content_for_secrets "$TEST_DIR/db.py")

  assert_equal "$result" "true" "File with password assignment should be flagged"

  cleanup_security_pattern_test_env
}

test_tier3_content_connection_string() {
  echo ""
  echo "Test 13: Tier 3 - files with connection strings should be flagged"

  setup_security_pattern_test_env

  # Create file with connection string
  cat > "$TEST_DIR/database.js" << 'EOF'
const connectionString = "mongodb://user:password@localhost:27017/mydb";
EOF

  local result
  result=$(check_content_for_secrets "$TEST_DIR/database.js")

  assert_equal "$result" "true" "File with connection string should be flagged"

  cleanup_security_pattern_test_env
}

test_tier3_no_secrets() {
  echo ""
  echo "Test 14: Tier 3 - files without secrets should NOT be flagged"

  setup_security_pattern_test_env

  # Create a normal config file
  cat > "$TEST_DIR/config.ts" << 'EOF'
export const config = {
  apiEndpoint: process.env.API_ENDPOINT,
  timeout: 5000,
  retries: 3
};
EOF

  local result
  result=$(check_content_for_secrets "$TEST_DIR/config.ts")

  assert_equal "$result" "false" "File without secrets should NOT be flagged"

  cleanup_security_pattern_test_env
}

# =============================================================================
# User Configuration Tests
# =============================================================================

test_config_additional_patterns() {
  echo ""
  echo "Test 15: User config - additional patterns should be respected"

  setup_security_pattern_test_env

  # Create config with additional patterns
  mkdir -p "$TEST_DIR/.claude"
  cat > "$TEST_DIR/.context-config.json" << 'EOF'
{
  "scanner": {
    "securityPatterns": {
      "additionalPatterns": ["*stripe*", "*payment*"]
    }
  }
}
EOF

  local stripe_result payment_result
  stripe_result=$(is_security_relevant "stripe.ts" "$TEST_DIR")
  payment_result=$(is_security_relevant "paymentProcessor.js" "$TEST_DIR")

  assert_equal "$stripe_result" "true" "stripe.ts should be flagged (custom pattern)"
  assert_equal "$payment_result" "true" "paymentProcessor.js should be flagged (custom pattern)"

  cleanup_security_pattern_test_env
}

test_config_exclusions() {
  echo ""
  echo "Test 16: User config - exclusion patterns should be respected"

  setup_security_pattern_test_env

  # Create config with exclusions
  mkdir -p "$TEST_DIR/.claude"
  cat > "$TEST_DIR/.context-config.json" << 'EOF'
{
  "scanner": {
    "securityPatterns": {
      "exclusions": ["*mock*", "*fixture*"]
    }
  }
}
EOF

  local mock_auth_result fixture_result
  mock_auth_result=$(is_security_relevant "mockAuth.ts" "$TEST_DIR")
  fixture_result=$(is_security_relevant "auth.fixture.ts" "$TEST_DIR")

  assert_equal "$mock_auth_result" "false" "mockAuth.ts should NOT be flagged (excluded)"
  assert_equal "$fixture_result" "false" "auth.fixture.ts should NOT be flagged (excluded)"

  cleanup_security_pattern_test_env
}

test_config_no_config() {
  echo ""
  echo "Test 17: Default behavior when no config exists"

  setup_security_pattern_test_env

  # No config file - should use defaults
  local auth_result keyboard_result
  auth_result=$(is_security_relevant "auth.ts" "$TEST_DIR")
  keyboard_result=$(is_security_relevant "keyboard.ts" "$TEST_DIR")

  assert_equal "$auth_result" "true" "auth.ts should be flagged with defaults"
  assert_equal "$keyboard_result" "false" "keyboard.ts should NOT be flagged with defaults"

  cleanup_security_pattern_test_env
}

# =============================================================================
# Edge Cases
# =============================================================================

test_edge_case_sensitivity() {
  echo ""
  echo "Test 18: Pattern matching should be case-insensitive"

  local auth_upper_result auth_mixed_result
  auth_upper_result=$(is_security_relevant "AUTH.ts")
  auth_mixed_result=$(is_security_relevant "AuthService.tsx")

  assert_equal "$auth_upper_result" "true" "AUTH.ts should be flagged"
  assert_equal "$auth_mixed_result" "true" "AuthService.tsx should be flagged"
}

test_edge_nested_paths() {
  echo ""
  echo "Test 19: Nested paths should be handled correctly"

  local nested_auth_result deep_login_result
  nested_auth_result=$(is_security_relevant "src/lib/auth/index.ts")
  deep_login_result=$(is_security_relevant "packages/core/login/handler.js")

  assert_equal "$nested_auth_result" "true" "Nested auth file should be flagged"
  assert_equal "$deep_login_result" "true" "Deep login file should be flagged"
}

test_edge_multiple_patterns() {
  echo ""
  echo "Test 20: Files matching multiple patterns should be flagged"

  local auth_session_result
  auth_session_result=$(is_security_relevant "authSession.ts")

  assert_equal "$auth_session_result" "true" "authSession.ts should be flagged"
}

# =============================================================================
# get_security_tier() Tests
# =============================================================================

test_get_security_tier() {
  echo ""
  echo "Test 21: get_security_tier() should return correct tier"

  local tier1 tier2 tier3 no_tier
  tier1=$(get_security_tier "auth.ts")
  tier2=$(get_security_tier "apiKey.ts")
  no_tier=$(get_security_tier "button.tsx")

  assert_equal "$tier1" "1" "auth.ts should be tier 1"
  assert_equal "$tier2" "1" "apiKey.ts should be tier 1"
  assert_equal "$no_tier" "0" "button.tsx should be tier 0 (not security relevant)"
}

# =============================================================================
# Run all tests
# =============================================================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Phase 7.2: Security Pattern Tests                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Tier 1 tests
test_tier1_auth_patterns
test_tier1_login_patterns
test_tier1_session_patterns
test_tier1_oauth_jwt_patterns
test_tier1_env_patterns

# Tier 2 tests
test_tier2_key_exclusions
test_tier2_password_exclusions
test_tier2_token_exclusions
test_tier2_secret_exclusions
test_tier2_api_directory_handling

# Tier 3 tests
test_tier3_content_hardcoded_secrets
test_tier3_content_password_assignment
test_tier3_content_connection_string
test_tier3_no_secrets

# Config tests
test_config_additional_patterns
test_config_exclusions
test_config_no_config

# Edge cases
test_edge_case_sensitivity
test_edge_nested_paths
test_edge_multiple_patterns
test_get_security_tier

print_test_summary
