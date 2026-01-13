#!/bin/bash
# test-phase3-agents.sh - Validation tests for Phase 3 code review agents
#
# Tests: codebase-scanner, security-reviewer, code-reviewer, synthesis-agent

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.claude/agents"
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
echo "║       Phase 3 Agents Validation            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: codebase-scanner agent
echo "━━━ Test: codebase-scanner Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/codebase-scanner.md" ]; then
    pass "codebase-scanner agent file exists"

    # Check for cache output
    if grep -q "codebase-context.json" "$AGENTS_DIR/codebase-scanner.md"; then
        pass "Specifies cache output location"
    else
        fail "Missing cache output specification"
    fi

    # Check for cache invalidation
    if grep -q "invalidat\|stale\|Cache Invalidation" "$AGENTS_DIR/codebase-scanner.md"; then
        pass "Includes cache invalidation logic"
    else
        fail "Missing cache invalidation logic"
    fi

    # Check for incremental mode
    if grep -q "incremental\|Incremental" "$AGENTS_DIR/codebase-scanner.md"; then
        pass "Supports incremental mode"
    else
        fail "Missing incremental mode support"
    fi
else
    fail "codebase-scanner agent not found"
fi

echo ""

# Test 2: security-reviewer agent
echo "━━━ Test: security-reviewer Agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/security-reviewer.md" ]; then
    pass "security-reviewer agent file exists"

    # Check for AuditFinding schema reference
    if grep -q "AuditFinding" "$AGENTS_DIR/security-reviewer.md"; then
        pass "References AuditFinding schema"
    else
        fail "Missing AuditFinding schema reference"
    fi

    # Check for verified object requirement
    if grep -q "verified" "$AGENTS_DIR/security-reviewer.md" && grep -q "vulnPatternSearched\|mitigationPatternSearched" "$AGENTS_DIR/security-reviewer.md"; then
        pass "Requires verified object with patterns"
    else
        fail "Missing verified object requirement"
    fi

    # Check for security patterns
    if grep -q "SQL injection\|XSS\|hardcoded\|injection" "$AGENTS_DIR/security-reviewer.md"; then
        pass "Documents security patterns to check"
    else
        fail "Missing security patterns documentation"
    fi

    # Check for false positive avoidance
    if grep -q "false positive\|False Positive" "$AGENTS_DIR/security-reviewer.md"; then
        pass "Documents false positive avoidance"
    else
        fail "Missing false positive guidance"
    fi
else
    fail "security-reviewer agent not found"
fi

echo ""

# Test 3: code-reviewer orchestrator
echo "━━━ Test: code-reviewer Orchestrator ━━━"
echo ""

if [ -f "$AGENTS_DIR/code-reviewer.md" ]; then
    pass "code-reviewer agent file exists"

    # Check for scanner-first ordering
    if grep -q "scanner.*first\|Step 1.*Scanner\|Run Codebase Scanner" "$AGENTS_DIR/code-reviewer.md"; then
        pass "Runs scanner before specialists"
    else
        fail "Missing scanner-first ordering"
    fi

    # Check for parallel execution
    if grep -q "parallel\|Parallel" "$AGENTS_DIR/code-reviewer.md"; then
        pass "Supports parallel specialist execution"
    else
        fail "Missing parallel execution support"
    fi

    # Check for AuditReport output
    if grep -q "AuditReport" "$AGENTS_DIR/code-reviewer.md"; then
        pass "Produces AuditReport output"
    else
        fail "Missing AuditReport output"
    fi

    # Check for synthesis-agent integration
    if grep -q "synthesis" "$AGENTS_DIR/code-reviewer.md"; then
        pass "Integrates with synthesis-agent"
    else
        fail "Missing synthesis-agent integration"
    fi
else
    fail "code-reviewer agent not found"
fi

echo ""

# Test 4: synthesis-agent
echo "━━━ Test: synthesis-agent ━━━"
echo ""

if [ -f "$AGENTS_DIR/synthesis-agent.md" ]; then
    pass "synthesis-agent file exists"

    # Check for deduplication
    if grep -q "deduplicate\|Deduplicate\|duplicate" "$AGENTS_DIR/synthesis-agent.md"; then
        pass "Implements deduplication logic"
    else
        fail "Missing deduplication logic"
    fi

    # Check for same file:line rule
    if grep -q "file.*line\|file:line" "$AGENTS_DIR/synthesis-agent.md"; then
        pass "Uses file:line for duplicate detection"
    else
        fail "Missing file:line duplicate rule"
    fi

    # Check for grade calculation
    if grep -q "grade\|Grade" "$AGENTS_DIR/synthesis-agent.md" && grep -q "A\+\|B\+\|C\+" "$AGENTS_DIR/synthesis-agent.md"; then
        pass "Calculates grade from severity counts"
    else
        fail "Missing grade calculation"
    fi

    # Check for merge logic
    if grep -q "merge\|Merge" "$AGENTS_DIR/synthesis-agent.md"; then
        pass "Merges findings from specialists"
    else
        fail "Missing merge logic"
    fi
else
    fail "synthesis-agent not found"
fi

echo ""

# Test 5: Schema coverage for code review
echo "━━━ Test: Code Review Schema Coverage ━━━"
echo ""

# AuditFinding schema
if [ -f "$SCHEMAS_DIR/audit-finding.json" ]; then
    pass "AuditFinding schema exists"

    if jq -e '.properties.verified.required | contains(["vulnPatternSearched", "mitigationPatternSearched", "mitigationFound"])' "$SCHEMAS_DIR/audit-finding.json" > /dev/null 2>&1; then
        pass "AuditFinding schema has verified requirements"
    else
        fail "AuditFinding schema missing verified requirements"
    fi
else
    fail "AuditFinding schema not found"
fi

# AuditReport schema
if [ -f "$SCHEMAS_DIR/audit-report.json" ]; then
    pass "AuditReport schema exists"

    if jq -e '.properties.summary.properties.grade' "$SCHEMAS_DIR/audit-report.json" > /dev/null 2>&1; then
        pass "AuditReport schema has grade field"
    else
        fail "AuditReport schema missing grade field"
    fi
else
    fail "AuditReport schema not found"
fi

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 3 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 3 tests PASSED${NC}"
    exit 0
fi
