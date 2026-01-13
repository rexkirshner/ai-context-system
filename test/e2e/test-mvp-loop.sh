#!/bin/bash
# test-mvp-loop.sh - End-to-end test for MVP loop skills
# Tests: init → work → save-full → review
#
# This test validates the OUTPUT formats are correct.
# Skills are AI instructions, so we test the expected artifacts.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$REPO_ROOT/test/fixtures"
GOLDEN_DIR="$REPO_ROOT/test/golden"
SCHEMAS_DIR="$REPO_ROOT/.claude/schemas"

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
echo "║       MVP Loop End-to-End Tests            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: Validate /init output format
echo "━━━ Test: /init Output Validation ━━━"
echo ""

# Check that init skill exists and has required sections
INIT_SKILL="$REPO_ROOT/.claude/skills/init/SKILL.md"
if [ -f "$INIT_SKILL" ]; then
    pass "Init skill file exists"

    # Check for required sections
    if grep -q "## Output" "$INIT_SKILL"; then
        pass "Init skill has Output section"
    else
        fail "Init skill missing Output section"
    fi

    if grep -q "## Verification Criteria" "$INIT_SKILL"; then
        pass "Init skill has Verification Criteria"
    else
        fail "Init skill missing Verification Criteria"
    fi

    # Check output structure matches expected
    if grep -q "CONTEXT.md" "$INIT_SKILL" && grep -q "STATUS.md" "$INIT_SKILL" && grep -q "SESSIONS.md" "$INIT_SKILL"; then
        pass "Init skill outputs correct files"
    else
        fail "Init skill missing required output files"
    fi
else
    fail "Init skill file not found"
fi

echo ""

# Test 2: Validate /review output format
echo "━━━ Test: /review Output Validation ━━━"
echo ""

REVIEW_SKILL="$REPO_ROOT/.claude/skills/review/SKILL.md"
if [ -f "$REVIEW_SKILL" ]; then
    pass "Review skill file exists"

    # Check for ContextHealth schema reference
    if grep -q "ContextHealth" "$REVIEW_SKILL"; then
        pass "Review skill references ContextHealth schema"
    else
        fail "Review skill missing ContextHealth schema reference"
    fi

    # Check for score calculation
    if grep -q "statusFreshness" "$REVIEW_SKILL" && grep -q "sessionsFreshness" "$REVIEW_SKILL"; then
        pass "Review skill has health score components"
    else
        fail "Review skill missing health score components"
    fi

    # Check for resume point format (must have verb list and location pattern)
    if grep -q "Resume" "$REVIEW_SKILL" && grep -qE "(allowed verb|Start with|verb)" "$REVIEW_SKILL"; then
        pass "Review skill has resume point format"
    else
        fail "Review skill missing resume point format"
    fi
else
    fail "Review skill file not found"
fi

echo ""

# Test 3: Validate /save-full output format
echo "━━━ Test: /save-full Output Validation ━━━"
echo ""

SAVE_SKILL="$REPO_ROOT/.claude/skills/save-full/SKILL.md"
if [ -f "$SAVE_SKILL" ]; then
    pass "Save-full skill file exists"

    # Check for SessionEntry schema reference
    if grep -q "SessionEntry" "$SAVE_SKILL"; then
        pass "Save-full skill references SessionEntry schema"
    else
        fail "Save-full skill missing SessionEntry schema reference"
    fi

    # Check for BEGIN/END markers
    if grep -q "BEGIN SESSION" "$SAVE_SKILL" && grep -q "END SESSION" "$SAVE_SKILL"; then
        pass "Save-full skill uses session markers"
    else
        fail "Save-full skill missing session markers"
    fi

    # Check for TL;DR requirement
    if grep -q "TL;DR" "$SAVE_SKILL" && grep -q "50-300" "$SAVE_SKILL"; then
        pass "Save-full skill has TL;DR length requirement"
    else
        fail "Save-full skill missing TL;DR requirement"
    fi
else
    fail "Save-full skill file not found"
fi

echo ""

# Test 4: Validate golden files match schemas
echo "━━━ Test: Golden File Validation ━━━"
echo ""

# Check audit-report.json against schema
if [ -f "$GOLDEN_DIR/audit-report.json" ]; then
    if python3 -m json.tool "$GOLDEN_DIR/audit-report.json" > /dev/null 2>&1; then
        pass "Golden audit-report.json is valid JSON"

        # Check required fields
        if jq -e '.metadata.timestamp' "$GOLDEN_DIR/audit-report.json" > /dev/null 2>&1; then
            pass "Golden audit-report has metadata.timestamp"
        else
            fail "Golden audit-report missing metadata.timestamp"
        fi

        if jq -e '.summary.grade' "$GOLDEN_DIR/audit-report.json" > /dev/null 2>&1; then
            pass "Golden audit-report has summary.grade"
        else
            fail "Golden audit-report missing summary.grade"
        fi

        if jq -e '.findings' "$GOLDEN_DIR/audit-report.json" > /dev/null 2>&1; then
            pass "Golden audit-report has findings array"
        else
            fail "Golden audit-report missing findings array"
        fi
    else
        fail "Golden audit-report.json is not valid JSON"
    fi
else
    fail "Golden audit-report.json not found"
fi

# Check session-entry.md format
if [ -f "$GOLDEN_DIR/session-entry.md" ]; then
    pass "Golden session-entry.md exists"

    if grep -q "BEGIN SESSION" "$GOLDEN_DIR/session-entry.md"; then
        pass "Golden session-entry has BEGIN marker"
    else
        fail "Golden session-entry missing BEGIN marker"
    fi

    if grep -q "END SESSION" "$GOLDEN_DIR/session-entry.md"; then
        pass "Golden session-entry has END marker"
    else
        fail "Golden session-entry missing END marker"
    fi

    if grep -q "### TL;DR" "$GOLDEN_DIR/session-entry.md"; then
        pass "Golden session-entry has TL;DR section"
    else
        fail "Golden session-entry missing TL;DR section"
    fi
else
    fail "Golden session-entry.md not found"
fi

# Check quick-reference.md format
if [ -f "$GOLDEN_DIR/quick-reference.md" ]; then
    pass "Golden quick-reference.md exists"

    if grep -q "BEGIN AUTO:QUICK_REFERENCE" "$GOLDEN_DIR/quick-reference.md"; then
        pass "Golden quick-reference has AUTO marker"
    else
        fail "Golden quick-reference missing AUTO marker"
    fi

    if grep -q "Resume:" "$GOLDEN_DIR/quick-reference.md"; then
        pass "Golden quick-reference has Resume field"
    else
        fail "Golden quick-reference missing Resume field"
    fi
else
    fail "Golden quick-reference.md not found"
fi

echo ""

# Test 5: Schema validation
echo "━━━ Test: JSON Schema Validation ━━━"
echo ""

SCHEMAS=(
    "context-health.json"
    "session-entry.json"
    "audit-report.json"
    "audit-finding.json"
    "handoff-package.json"
)

for schema in "${SCHEMAS[@]}"; do
    if [ -f "$SCHEMAS_DIR/$schema" ]; then
        if python3 -m json.tool "$SCHEMAS_DIR/$schema" > /dev/null 2>&1; then
            # Check for required schema fields
            if jq -e '."$schema"' "$SCHEMAS_DIR/$schema" > /dev/null 2>&1; then
                pass "$schema has \$schema field"
            else
                fail "$schema missing \$schema field"
            fi

            if jq -e '.type' "$SCHEMAS_DIR/$schema" > /dev/null 2>&1; then
                pass "$schema has type field"
            else
                fail "$schema missing type field"
            fi
        else
            fail "$schema is not valid JSON"
        fi
    else
        fail "$schema not found"
    fi
done

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}MVP Loop tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}MVP Loop tests PASSED${NC}"
    exit 0
fi
