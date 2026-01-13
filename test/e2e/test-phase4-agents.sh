#!/bin/bash
# test-phase4-agents.sh - Validation tests for Phase 4 remaining agents
#
# Tests: performance-reviewer, accessibility-reviewer, type-safety-reviewer, test-coverage-reviewer, audit-compare

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.claude/agents"

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
echo "║       Phase 4 Agents Validation            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: performance-reviewer agent
echo "━━━ Test: performance-reviewer Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/performance-reviewer.md" ]; then
    pass "performance-reviewer agent file exists"

    # Check for AuditFinding output
    if grep -q "AuditFinding" "$AGENTS_DIR/performance-reviewer.md"; then
        pass "Produces AuditFinding output"
    else
        fail "Missing AuditFinding output"
    fi

    # Check for verified object
    if grep -q "verified" "$AGENTS_DIR/performance-reviewer.md" && grep -q "vulnPatternSearched\|mitigationPatternSearched" "$AGENTS_DIR/performance-reviewer.md"; then
        pass "Requires verified object"
    else
        fail "Missing verified object requirement"
    fi

    # Check for performance patterns
    if grep -q "N+1\|sequential\|memoization\|bundle" "$AGENTS_DIR/performance-reviewer.md"; then
        pass "Documents performance patterns to check"
    else
        fail "Missing performance patterns"
    fi

    # Check for false positive guidance
    if grep -q "false positive\|False Positive" "$AGENTS_DIR/performance-reviewer.md"; then
        pass "Documents false positive avoidance"
    else
        fail "Missing false positive guidance"
    fi
else
    fail "performance-reviewer agent not found"
fi

echo ""

# Test 2: accessibility-reviewer agent
echo "━━━ Test: accessibility-reviewer Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/accessibility-reviewer.md" ]; then
    pass "accessibility-reviewer agent file exists"

    # Check for WCAG reference
    if grep -q "WCAG" "$AGENTS_DIR/accessibility-reviewer.md"; then
        pass "References WCAG guidelines"
    else
        fail "Missing WCAG reference"
    fi

    # Check for a11y patterns
    if grep -q "alt text\|aria-\|label\|focus" "$AGENTS_DIR/accessibility-reviewer.md"; then
        pass "Documents accessibility patterns"
    else
        fail "Missing accessibility patterns"
    fi

    # Check for verified object
    if grep -q "verified" "$AGENTS_DIR/accessibility-reviewer.md" && grep -q "vulnPatternSearched" "$AGENTS_DIR/accessibility-reviewer.md"; then
        pass "Requires verified object"
    else
        fail "Missing verified object requirement"
    fi

    # Check for severity levels
    if grep -q "High Severity\|Medium Severity\|Low Severity" "$AGENTS_DIR/accessibility-reviewer.md"; then
        pass "Has severity level guidance"
    else
        fail "Missing severity level guidance"
    fi
else
    fail "accessibility-reviewer agent not found"
fi

echo ""

# Test 3: type-safety-reviewer agent
echo "━━━ Test: type-safety-reviewer Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/type-safety-reviewer.md" ]; then
    pass "type-safety-reviewer agent file exists"

    # Check for TypeScript patterns
    if grep -q "any\|@ts-ignore\|strict" "$AGENTS_DIR/type-safety-reviewer.md"; then
        pass "Documents TypeScript patterns to check"
    else
        fail "Missing TypeScript patterns"
    fi

    # Check for tsconfig reference
    if grep -q "tsconfig" "$AGENTS_DIR/type-safety-reviewer.md"; then
        pass "References tsconfig settings"
    else
        fail "Missing tsconfig reference"
    fi

    # Check for verified object
    if grep -q "verified" "$AGENTS_DIR/type-safety-reviewer.md" && grep -q "mitigationFound" "$AGENTS_DIR/type-safety-reviewer.md"; then
        pass "Requires verified object"
    else
        fail "Missing verified object requirement"
    fi

    # Check for strictness levels
    if grep -q "noImplicitAny\|strictNullChecks" "$AGENTS_DIR/type-safety-reviewer.md"; then
        pass "Documents strictness levels"
    else
        fail "Missing strictness level guidance"
    fi
else
    fail "type-safety-reviewer agent not found"
fi

echo ""

# Test 4: test-coverage-reviewer agent
echo "━━━ Test: test-coverage-reviewer Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/test-coverage-reviewer.md" ]; then
    pass "test-coverage-reviewer agent file exists"

    # Check for coverage patterns
    if grep -q "untested\|coverage\|\.test\.\|\.spec\." "$AGENTS_DIR/test-coverage-reviewer.md"; then
        pass "Documents coverage patterns"
    else
        fail "Missing coverage patterns"
    fi

    # Check for critical path focus
    if grep -q "auth\|payment\|security" "$AGENTS_DIR/test-coverage-reviewer.md"; then
        pass "Focuses on critical paths"
    else
        fail "Missing critical path focus"
    fi

    # Check for verified object
    if grep -q "verified" "$AGENTS_DIR/test-coverage-reviewer.md" && grep -q "mitigationPatternSearched" "$AGENTS_DIR/test-coverage-reviewer.md"; then
        pass "Requires verified object"
    else
        fail "Missing verified object requirement"
    fi

    # Check for test quality indicators
    if grep -q "Good\|Bad\|anti-pattern" "$AGENTS_DIR/test-coverage-reviewer.md"; then
        pass "Includes test quality guidance"
    else
        fail "Missing test quality guidance"
    fi
else
    fail "test-coverage-reviewer agent not found"
fi

echo ""

# Test 5: audit-compare agent
echo "━━━ Test: audit-compare Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/audit-compare.md" ]; then
    pass "audit-compare agent file exists"

    # Check for trend tracking
    if grep -q "trend\|Trend\|direction" "$AGENTS_DIR/audit-compare.md"; then
        pass "Tracks trends"
    else
        fail "Missing trend tracking"
    fi

    # Check for grade comparison
    if grep -q "gradeChange\|Grade Change" "$AGENTS_DIR/audit-compare.md"; then
        pass "Compares grades"
    else
        fail "Missing grade comparison"
    fi

    # Check for resolved/new findings
    if grep -q "resolved\|Resolved" "$AGENTS_DIR/audit-compare.md" && grep -q "new\|New" "$AGENTS_DIR/audit-compare.md"; then
        pass "Tracks resolved and new findings"
    else
        fail "Missing resolved/new tracking"
    fi

    # Check for previous report lookup
    if grep -q "archive\|previous" "$AGENTS_DIR/audit-compare.md"; then
        pass "Reads previous reports from archive"
    else
        fail "Missing previous report lookup"
    fi
else
    fail "audit-compare agent not found"
fi

echo ""

# Test 6: All agents follow consistent structure
echo "━━━ Test: Agent Structure Consistency ━━━"
echo ""

AGENTS=("performance-reviewer" "accessibility-reviewer" "type-safety-reviewer" "test-coverage-reviewer")

for agent in "${AGENTS[@]}"; do
    if [ -f "$AGENTS_DIR/$agent.md" ]; then
        # Check for required sections
        if grep -q "## Purpose" "$AGENTS_DIR/$agent.md"; then
            pass "$agent has Purpose section"
        else
            fail "$agent missing Purpose section"
        fi

        if grep -q "## Input" "$AGENTS_DIR/$agent.md"; then
            pass "$agent has Input section"
        else
            fail "$agent missing Input section"
        fi

        if grep -q "## Output" "$AGENTS_DIR/$agent.md"; then
            pass "$agent has Output section"
        else
            fail "$agent missing Output section"
        fi

        if grep -q "## Verification Criteria" "$AGENTS_DIR/$agent.md"; then
            pass "$agent has Verification Criteria"
        else
            fail "$agent missing Verification Criteria"
        fi
    fi
done

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 4 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 4 tests PASSED${NC}"
    exit 0
fi
