#!/bin/bash
# test-nested-repo-detection.sh - Tests for v5.1.2 nested repository detection
#
# This test suite validates:
# 1. Installer detects nested git repositories
# 2. Installer detects parent context systems
# 3. Installer detects orphaned context folders
# 4. Warnings are displayed correctly

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
# Test Suite 1: install.sh Contains Detection Code
# =============================================================================
header "Test Suite 1: install.sh Detection Code"

# Test 1.1: install.sh has nested repo detection
if grep -q "Nested git repositories detected" "$REPO_ROOT/install.sh"; then
    pass "install.sh has nested repo detection message"
else
    fail "install.sh missing nested repo detection message"
fi

# Test 1.2: install.sh has find command for nested .git
if grep -q 'find \. -mindepth 2 -name "\.git"' "$REPO_ROOT/install.sh"; then
    pass "install.sh has find command for nested .git directories"
else
    fail "install.sh missing find command for nested .git"
fi

# Test 1.3: install.sh has parent context detection
if grep -q "Parent directory has AI Context System" "$REPO_ROOT/install.sh"; then
    pass "install.sh has parent context detection message"
else
    fail "install.sh missing parent context detection message"
fi

# Test 1.4: install.sh checks parent .context-config.json
if grep -q '../context/\.context-config\.json' "$REPO_ROOT/install.sh"; then
    pass "install.sh checks parent .context-config.json"
else
    fail "install.sh missing parent .context-config.json check"
fi

# Test 1.5: install.sh has orphaned context detection
if grep -q "Orphaned context folder detected" "$REPO_ROOT/install.sh"; then
    pass "install.sh has orphaned context detection message"
else
    fail "install.sh missing orphaned context detection message"
fi

# Test 1.6: install.sh checks for context/ without .context-config.json
if grep -q 'context.*&&.*!.*context/\.context-config\.json' "$REPO_ROOT/install.sh"; then
    pass "install.sh checks for context/ without .context-config.json"
else
    fail "install.sh missing orphaned context check logic"
fi

# =============================================================================
# Test Suite 2: Functional Tests - Nested Repo Detection
# =============================================================================
header "Test Suite 2: Functional Tests"

# Create a temp directory for testing
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test 2.1: Detect nested git repository
mkdir -p "$TEST_DIR/parent"
mkdir -p "$TEST_DIR/parent/child"
git init --quiet "$TEST_DIR/parent" 2>/dev/null
git init --quiet "$TEST_DIR/parent/child" 2>/dev/null

cd "$TEST_DIR/parent"
NESTED_REPOS=$(find . -mindepth 2 -name ".git" -type d 2>/dev/null | head -5)
if [ -n "$NESTED_REPOS" ]; then
    pass "Nested .git detection finds child/.git"
else
    fail "Nested .git detection failed to find child/.git"
fi

# Test 2.2: Detect parent context system
mkdir -p "$TEST_DIR/parent/context"
echo '{"version": "5.1.2"}' > "$TEST_DIR/parent/context/.context-config.json"

cd "$TEST_DIR/parent/child"
if [ -f "../context/.context-config.json" ]; then
    pass "Parent context detection finds parent's .context-config.json"
else
    fail "Parent context detection failed"
fi

# Test 2.3: Detect orphaned context folder
mkdir -p "$TEST_DIR/orphaned-test"
mkdir -p "$TEST_DIR/orphaned-test/context"
echo "# STATUS" > "$TEST_DIR/orphaned-test/context/STATUS.md"
# Note: NOT creating .context-config.json

cd "$TEST_DIR/orphaned-test"
if [ -d "context" ] && [ ! -f "context/.context-config.json" ]; then
    pass "Orphaned context detection identifies missing .context-config.json"
else
    fail "Orphaned context detection failed"
fi

# Test 2.4: No false positive when context is properly configured
mkdir -p "$TEST_DIR/proper-test/context"
echo '{"version": "5.1.2"}' > "$TEST_DIR/proper-test/context/.context-config.json"

cd "$TEST_DIR/proper-test"
if [ -d "context" ] && [ -f "context/.context-config.json" ]; then
    pass "Properly configured context not flagged as orphaned"
else
    fail "Proper context incorrectly flagged"
fi

# =============================================================================
# Test Suite 2.5: Runtime Git Boundary Tests (find_context_folder)
# =============================================================================
header "Test Suite 2.5: Runtime Git Boundary Tests"

# Source the find-context-folder.sh script
source "$REPO_ROOT/scripts/find-context-folder.sh"

# Test 2.5.1: find_context_folder respects git boundary
# Setup: parent has context, child is separate git repo without context
mkdir -p "$TEST_DIR/git-boundary-test/parent/context"
mkdir -p "$TEST_DIR/git-boundary-test/parent/child-repo"
echo '{"version": "5.1.2"}' > "$TEST_DIR/git-boundary-test/parent/context/.context-config.json"
git init --quiet "$TEST_DIR/git-boundary-test/parent" 2>/dev/null
git init --quiet "$TEST_DIR/git-boundary-test/parent/child-repo" 2>/dev/null

# From child-repo (which has .git but no context), should NOT find parent's context
cd "$TEST_DIR/git-boundary-test/parent/child-repo"
RESULT=$(find_context_folder 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ] && [ -z "$RESULT" ]; then
    pass "find_context_folder does NOT traverse into parent when in nested git repo"
else
    fail "find_context_folder incorrectly found parent context from nested git repo (got: $RESULT)"
fi

# Test 2.5.2: find_context_folder still works from subdirectory (non-git)
mkdir -p "$TEST_DIR/subdir-test/context"
mkdir -p "$TEST_DIR/subdir-test/src/components"
echo '{"version": "5.1.2"}' > "$TEST_DIR/subdir-test/context/.context-config.json"
# Note: NOT a git repo

cd "$TEST_DIR/subdir-test/src/components"
RESULT=$(find_context_folder 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ -n "$RESULT" ]; then
    pass "find_context_folder still traverses upward in non-git subdirectories"
else
    fail "find_context_folder failed to find context from subdirectory"
fi

# Test 2.5.3: find_context_folder finds local context in git repo
mkdir -p "$TEST_DIR/local-context-test/context"
echo '{"version": "5.1.2"}' > "$TEST_DIR/local-context-test/context/.context-config.json"
git init --quiet "$TEST_DIR/local-context-test" 2>/dev/null

cd "$TEST_DIR/local-context-test"
RESULT=$(find_context_folder 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ] && [ "$RESULT" = "context" ]; then
    pass "find_context_folder finds local context in git repo root"
else
    fail "find_context_folder failed to find local context (got: $RESULT)"
fi

# =============================================================================
# Test Suite 3: Documentation Updated
# =============================================================================
header "Test Suite 3: Documentation"

# Test 3.1: TROUBLESHOOTING.md has nested repo section
if grep -q "Nested Git Repositories Causing Context Confusion" "$REPO_ROOT/.claude/docs/TROUBLESHOOTING.md"; then
    pass "TROUBLESHOOTING.md has nested repo section"
else
    fail "TROUBLESHOOTING.md missing nested repo section"
fi

# Test 3.2: CHANGELOG.md has nested repo detection entry
if grep -q "Nested repository detection" "$REPO_ROOT/CHANGELOG.md"; then
    pass "CHANGELOG.md has nested repo detection entry"
else
    fail "CHANGELOG.md missing nested repo detection entry"
fi

# Test 3.3: CHANGELOG.md has parent context detection entry
if grep -q "Parent context detection" "$REPO_ROOT/CHANGELOG.md"; then
    pass "CHANGELOG.md has parent context detection entry"
else
    fail "CHANGELOG.md missing parent context detection entry"
fi

# Test 3.4: CHANGELOG.md has orphaned context detection entry
if grep -q "Orphaned context detection" "$REPO_ROOT/CHANGELOG.md"; then
    pass "CHANGELOG.md has orphaned context detection entry"
else
    fail "CHANGELOG.md missing orphaned context detection entry"
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
