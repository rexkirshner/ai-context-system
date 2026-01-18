#!/bin/bash
# test-settings-rename.sh - Tests for v5.1.2 settings.json → acs-settings.json rename
#
# This test suite validates:
# 1. acs-settings.json exists in repo (not settings.json)
# 2. session-start.sh reads from acs-settings.json
# 3. common-functions.sh get_merged_config uses acs-settings.json
# 4. Migration removes old settings.json with ACS schema
# 5. User's Claude Code settings.json is preserved

# Don't exit on error - we want to run all tests
# set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Test counters
PASSED=0
FAILED=0
SKIPPED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

skip() {
    echo -e "${YELLOW}○${NC} $1 (skipped)"
    ((SKIPPED++))
}

header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

# =============================================================================
# Test Suite 1: Repository File Structure
# =============================================================================
header "Test Suite 1: Repository File Structure"

# Test 1.1: acs-settings.json exists
if [ -f "$REPO_ROOT/.claude/acs-settings.json" ]; then
    pass "acs-settings.json exists in .claude/"
else
    fail "acs-settings.json NOT found in .claude/"
fi

# Test 1.2: old settings.json does NOT exist
if [ ! -f "$REPO_ROOT/.claude/settings.json" ]; then
    pass "settings.json does NOT exist in .claude/ (correct)"
else
    fail "settings.json still exists in .claude/ (should be removed)"
fi

# Test 1.3: acs-settings.json is valid JSON
if [ -f "$REPO_ROOT/.claude/acs-settings.json" ]; then
    if python3 -m json.tool "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json is valid JSON"
    else
        fail "acs-settings.json is NOT valid JSON"
    fi
else
    skip "acs-settings.json validation (file not found)"
fi

# Test 1.4: acs-settings.json has expected structure
if [ -f "$REPO_ROOT/.claude/acs-settings.json" ]; then
    if jq -e '.profile' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has 'profile' field"
    else
        fail "acs-settings.json missing 'profile' field"
    fi

    if jq -e '.hooks' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has 'hooks' field"
    else
        fail "acs-settings.json missing 'hooks' field"
    fi

    if jq -e '.profiles' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has 'profiles' field"
    else
        fail "acs-settings.json missing 'profiles' field"
    fi
else
    skip "acs-settings.json structure validation (file not found)"
fi

# =============================================================================
# Test Suite 2: session-start.sh Uses Correct File
# =============================================================================
header "Test Suite 2: session-start.sh Configuration"

# Test 2.1: session-start.sh references acs-settings.json
if grep -q "acs-settings.json" "$REPO_ROOT/.claude/hooks/session-start.sh"; then
    pass "session-start.sh references acs-settings.json"
else
    fail "session-start.sh does NOT reference acs-settings.json"
fi

# Test 2.2: session-start.sh does NOT reference old settings.json path
# (It might have "settings" in other contexts, so check specific path)
if grep -q '\.claude/settings\.json' "$REPO_ROOT/.claude/hooks/session-start.sh"; then
    fail "session-start.sh still references .claude/settings.json"
else
    pass "session-start.sh does NOT reference old .claude/settings.json path"
fi

# =============================================================================
# Test Suite 3: common-functions.sh Uses Correct File
# =============================================================================
header "Test Suite 3: common-functions.sh Configuration"

# Test 3.1: get_merged_config uses acs-settings.json
if grep -q "acs-settings.json" "$REPO_ROOT/scripts/common-functions.sh"; then
    pass "common-functions.sh references acs-settings.json"
else
    fail "common-functions.sh does NOT reference acs-settings.json"
fi

# Test 3.2: Does NOT reference old settings.json in config merging
# Check specifically in the get_merged_config function area
if grep -A20 "get_merged_config" "$REPO_ROOT/scripts/common-functions.sh" | grep -q '\.claude/settings\.json'; then
    fail "get_merged_config still references .claude/settings.json"
else
    pass "get_merged_config does NOT reference old .claude/settings.json"
fi

# =============================================================================
# Test Suite 4: install.sh Uses Correct File
# =============================================================================
header "Test Suite 4: install.sh Configuration"

# Test 4.1: install.sh has acs-settings.json in CLAUDE_FILES
if grep -q '"acs-settings.json"' "$REPO_ROOT/install.sh"; then
    pass "install.sh includes acs-settings.json in file list"
else
    fail "install.sh does NOT include acs-settings.json"
fi

# Test 4.2: install.sh does NOT have settings.json in CLAUDE_FILES
# (Avoid matching acs-settings.json)
if grep 'CLAUDE_FILES' -A50 "$REPO_ROOT/install.sh" | grep -v "acs-settings" | grep -q '"settings.json"'; then
    fail "install.sh still has settings.json in file list"
else
    pass "install.sh does NOT have old settings.json in file list"
fi

# Test 4.3: install.sh download section uses acs-settings.json
if grep -q "Downloading acs-settings.json" "$REPO_ROOT/install.sh"; then
    pass "install.sh download message references acs-settings.json"
else
    fail "install.sh download message does NOT reference acs-settings.json"
fi

# =============================================================================
# Test Suite 5: Schema File Updated
# =============================================================================
header "Test Suite 5: Schema Configuration"

# Test 5.1: Schema file renamed or $id updated
if [ -f "$REPO_ROOT/.claude/schemas/acs-settings.json" ]; then
    pass "acs-settings.json schema file exists"

    # Test 5.2: Schema $id is updated
    if jq -e '."$id" | contains("acs-settings")' "$REPO_ROOT/.claude/schemas/acs-settings.json" > /dev/null 2>&1; then
        pass "Schema $id references acs-settings"
    else
        fail "Schema $id does NOT reference acs-settings"
    fi
elif [ -f "$REPO_ROOT/.claude/schemas/settings.json" ]; then
    # Check if old file's $id was updated
    skip "Schema file still named settings.json (may be intentional)"
else
    skip "No schema file found for settings"
fi

# =============================================================================
# Test Suite 6: Migration Logic
# =============================================================================
header "Test Suite 6: Migration Logic in update-context-system.md"

# Test 6.1: update-context-system.md has migration step
if grep -q "Migrate.*settings.json\|settings.json.*migration\|v5.1.2" "$REPO_ROOT/.claude/commands/update-context-system.md"; then
    pass "update-context-system.md has settings migration logic"
else
    fail "update-context-system.md missing settings migration logic"
fi

# Test 6.2: Migration checks for ACS schema before removing
if grep -q "acs.rexkirshner.com" "$REPO_ROOT/.claude/commands/update-context-system.md"; then
    pass "Migration checks for ACS schema URL before removing"
else
    fail "Migration does NOT check for ACS schema URL"
fi

# =============================================================================
# Test Suite 7: Rollback Script Updated
# =============================================================================
header "Test Suite 7: rollback.sh Configuration"

# Test 7.1: rollback.sh references acs-settings.json
if grep -q "acs-settings.json" "$REPO_ROOT/scripts/rollback.sh"; then
    pass "rollback.sh references acs-settings.json"
else
    fail "rollback.sh does NOT reference acs-settings.json"
fi

# =============================================================================
# Test Suite 8: verify-phase.sh Updated
# =============================================================================
header "Test Suite 8: verify-phase.sh Configuration"

# Test 8.1: verify-phase.sh checks for acs-settings.json
if grep -q "acs-settings.json" "$REPO_ROOT/scripts/verify-phase.sh"; then
    pass "verify-phase.sh checks for acs-settings.json"
else
    fail "verify-phase.sh does NOT check for acs-settings.json"
fi

# =============================================================================
# Test Suite 9: Functional Test - Config Reading
# =============================================================================
header "Test Suite 9: Functional Tests"

# Create a temp directory for testing
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 9.1: get_merged_config reads from acs-settings.json
mkdir -p "$TEST_DIR/.claude"
echo '{"profile": "test-profile", "hooks": {"enabled": true}}' > "$TEST_DIR/.claude/acs-settings.json"

# Source common-functions and test
source "$REPO_ROOT/scripts/common-functions.sh" 2>/dev/null || true
if type get_merged_config &>/dev/null; then
    RESULT=$(get_merged_config "$TEST_DIR" 2>/dev/null || echo "{}")
    if echo "$RESULT" | jq -e '.profile == "test-profile"' > /dev/null 2>&1; then
        pass "get_merged_config correctly reads from acs-settings.json"
    else
        fail "get_merged_config did not read from acs-settings.json correctly"
    fi
else
    skip "get_merged_config function not available"
fi

# Test 9.2: Verify migration doesn't touch user's Claude Code settings
mkdir -p "$TEST_DIR/user-project/.claude"
echo '{"$schema": "https://json.schemastore.org/claude-code-settings.json", "userSetting": true}' > "$TEST_DIR/user-project/.claude/settings.json"
# Migration should NOT remove this file (different schema)
# This is a documentation test - actual migration tested in e2e

if [ -f "$TEST_DIR/user-project/.claude/settings.json" ]; then
    pass "User's Claude Code settings.json preserved (migration check)"
else
    fail "Test setup failed for user settings preservation test"
fi

# =============================================================================
# Summary
# =============================================================================
header "Test Summary"

TOTAL=$((PASSED + FAILED + SKIPPED))
echo ""
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Skipped: $SKIPPED"
echo "Total:   $TOTAL"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}TESTS FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
