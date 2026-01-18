#!/bin/bash
# test-phase5-hooks.sh - Validation tests for Phase 5 hooks
#
# Tests: session-start.sh, acs-settings.json, safe-fail behavior

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOKS_DIR="$REPO_ROOT/.claude/hooks"
FIXTURES_DIR="$REPO_ROOT/test/fixtures"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

echo "╔════════════════════════════════════════════╗"
echo "║       Phase 5 Hooks Validation             ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: Hook file exists and is executable
echo "━━━ Test: Hook File Structure ━━━"
echo ""

if [ -f "$HOOKS_DIR/session-start.sh" ]; then
    pass "session-start.sh exists"
else
    fail "session-start.sh not found"
fi

if [ -x "$HOOKS_DIR/session-start.sh" ]; then
    pass "session-start.sh is executable"
else
    fail "session-start.sh is not executable"
fi

# Check for shebang
if head -1 "$HOOKS_DIR/session-start.sh" | grep -q "#!/bin/bash"; then
    pass "session-start.sh has bash shebang"
else
    fail "session-start.sh missing bash shebang"
fi

# Check for safety documentation
if grep -q "SAFETY" "$HOOKS_DIR/session-start.sh"; then
    pass "session-start.sh documents safety rules"
else
    fail "session-start.sh missing safety documentation"
fi

echo ""

# Test 2: Settings file exists
echo "━━━ Test: Settings Configuration ━━━"
echo ""

if [ -f "$REPO_ROOT/.claude/acs-settings.json" ]; then
    pass "acs-settings.json exists"

    # Validate JSON
    if python3 -m json.tool "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json is valid JSON"
    else
        fail "acs-settings.json is invalid JSON"
    fi

    # Check for profiles
    if jq -e '.profiles.minimal' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has minimal profile"
    else
        fail "acs-settings.json missing minimal profile"
    fi

    if jq -e '.profiles.standard' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has standard profile"
    else
        fail "acs-settings.json missing standard profile"
    fi

    # Check for hook timeout setting
    if jq -e '.hooks.timeout' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has hook timeout"
    else
        fail "acs-settings.json missing hook timeout"
    fi

    # Check for onFailure setting
    if jq -e '.hooks.onFailure' "$REPO_ROOT/.claude/acs-settings.json" > /dev/null 2>&1; then
        pass "acs-settings.json has onFailure setting"
    else
        fail "acs-settings.json missing onFailure setting"
    fi
else
    fail "acs-settings.json not found"
fi

echo ""

# Test 3: Hook execution tests
echo "━━━ Test: Hook Execution ━━━"
echo ""

# Test in a directory without context (should exit silently)
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

OUTPUT=$("$HOOKS_DIR/session-start.sh" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    pass "Hook exits 0 when no context directory"
else
    fail "Hook should exit 0 when no context directory (got $EXIT_CODE)"
fi

if [ -z "$OUTPUT" ]; then
    pass "Hook silent when no context directory"
else
    fail "Hook should be silent when no context directory"
fi

# Clean up
cd "$REPO_ROOT"
rm -rf "$TEMP_DIR"

# Test with fixture that has context
FIXTURE="$FIXTURES_DIR/nextjs-app"
if [ -d "$FIXTURE" ]; then
    cd "$FIXTURE"

    OUTPUT=$("$HOOKS_DIR/session-start.sh" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        pass "Hook exits 0 with valid context"
    else
        fail "Hook should exit 0 with valid context (got $EXIT_CODE)"
    fi

    if echo "$OUTPUT" | grep -q "ACS"; then
        pass "Hook outputs ACS status"
    else
        fail "Hook should output ACS status"
    fi

    cd "$REPO_ROOT"
fi

echo ""

# Test 4: Safe-fail rules
echo "━━━ Test: Safe-Fail Rules ━━━"
echo ""

# Check hook doesn't have forbidden operations
if ! grep -q "curl\|wget\|fetch" "$HOOKS_DIR/session-start.sh"; then
    pass "Hook has no network requests"
else
    fail "Hook contains network requests (forbidden)"
fi

if ! grep -q "git log\|git blame\|git show" "$HOOKS_DIR/session-start.sh"; then
    pass "Hook has no heavy git operations"
else
    fail "Hook contains heavy git operations (forbidden)"
fi

if ! grep -q "read -\|select\|prompt" "$HOOKS_DIR/session-start.sh"; then
    pass "Hook has no interactive prompts"
else
    fail "Hook contains interactive prompts (forbidden)"
fi

# Check hook is idempotent (running twice gives same result)
if [ -d "$FIXTURE" ]; then
    cd "$FIXTURE"
    OUTPUT1=$("$HOOKS_DIR/session-start.sh" 2>&1)
    OUTPUT2=$("$HOOKS_DIR/session-start.sh" 2>&1)
    cd "$REPO_ROOT"

    if [ "$OUTPUT1" = "$OUTPUT2" ]; then
        pass "Hook is idempotent"
    else
        fail "Hook is not idempotent (different outputs)"
    fi
fi

echo ""

# Test 5: Minimal profile respects hooks disabled
echo "━━━ Test: Profile Handling ━━━"
echo ""

# Check that hook checks for profile
if grep -q "profile\|minimal" "$HOOKS_DIR/session-start.sh"; then
    pass "Hook checks for profile setting"
else
    fail "Hook doesn't check for profile"
fi

# Check that minimal disables hooks in settings
MINIMAL_HOOKS=$(jq -r '.profiles.minimal.hooks | length' "$REPO_ROOT/.claude/acs-settings.json" 2>/dev/null || echo "1")
if [ "$MINIMAL_HOOKS" = "0" ]; then
    pass "Minimal profile has no hooks"
else
    fail "Minimal profile should have empty hooks array"
fi

echo ""

# Test 6: Hook timeout configuration
echo "━━━ Test: Timeout Configuration ━━━"
echo ""

TIMEOUT=$(jq -r '.hooks.timeout' "$REPO_ROOT/.claude/acs-settings.json" 2>/dev/null || echo "0")
if [ "$TIMEOUT" = "2000" ]; then
    pass "Hook timeout is 2 seconds (2000ms)"
else
    fail "Hook timeout should be 2000ms (got $TIMEOUT)"
fi

# Check that onFailure is warn
ONFAILURE=$(jq -r '.hooks.onFailure' "$REPO_ROOT/.claude/acs-settings.json" 2>/dev/null || echo "")
if [ "$ONFAILURE" = "warn" ]; then
    pass "onFailure is set to warn"
else
    fail "onFailure should be 'warn' (got $ONFAILURE)"
fi

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 5 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 5 tests PASSED${NC}"
    exit 0
fi
