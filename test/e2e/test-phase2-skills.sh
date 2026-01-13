#!/bin/bash
# test-phase2-skills.sh - Validation tests for Phase 2 skills
#
# Tests: /save, /validate, /export, /update

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMAS_DIR="$REPO_ROOT/.claude/schemas"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

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
echo "║       Phase 2 Skills Validation            ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Test 1: /save skill validation
echo "━━━ Test: /save Skill ━━━"
echo ""

SAVE_SKILL="$SKILLS_DIR/save/SKILL.md"
if [ -f "$SAVE_SKILL" ]; then
    pass "Save skill file exists"

    # Check for Quick Reference handling
    if grep -q "QUICK_REFERENCE" "$SAVE_SKILL"; then
        pass "Save skill handles Quick Reference block"
    else
        fail "Save skill missing Quick Reference handling"
    fi

    # Check for STATUS.md focus
    if grep -q "STATUS.md" "$SAVE_SKILL" && grep -q "only" "$SAVE_SKILL"; then
        pass "Save skill focuses on STATUS.md only"
    else
        fail "Save skill not clear about STATUS.md-only scope"
    fi

    # Check verification criteria
    if grep -q "## Verification Criteria" "$SAVE_SKILL"; then
        pass "Save skill has verification criteria"
    else
        fail "Save skill missing verification criteria"
    fi
else
    fail "Save skill file not found"
fi

echo ""

# Test 2: /validate skill validation
echo "━━━ Test: /validate Skill ━━━"
echo ""

VALIDATE_SKILL="$SKILLS_DIR/validate/SKILL.md"
if [ -f "$VALIDATE_SKILL" ]; then
    pass "Validate skill file exists"

    # Check for cross-reference validation
    if grep -q "D[0-9]" "$VALIDATE_SKILL" && grep -q "cross-reference\|Cross-Reference" "$VALIDATE_SKILL"; then
        pass "Validate skill checks cross-references"
    else
        fail "Validate skill missing cross-reference validation"
    fi

    # Check for D999 detection capability
    if grep -q "D999" "$VALIDATE_SKILL"; then
        pass "Validate skill documents D999 test case"
    else
        fail "Validate skill missing D999 test case documentation"
    fi

    # Check for session marker validation
    if grep -q "BEGIN SESSION\|END SESSION" "$VALIDATE_SKILL"; then
        pass "Validate skill checks session markers"
    else
        fail "Validate skill missing session marker validation"
    fi
else
    fail "Validate skill file not found"
fi

echo ""

# Test 3: /export skill validation
echo "━━━ Test: /export Skill ━━━"
echo ""

EXPORT_SKILL="$SKILLS_DIR/export/SKILL.md"
if [ -f "$EXPORT_SKILL" ]; then
    pass "Export skill file exists"

    # Check for HandoffPackage schema reference
    if grep -q "HandoffPackage" "$EXPORT_SKILL"; then
        pass "Export skill references HandoffPackage schema"
    else
        fail "Export skill missing HandoffPackage schema reference"
    fi

    # Check for JSON output
    if grep -q "\.json" "$EXPORT_SKILL" && grep -q "artifacts/exports" "$EXPORT_SKILL"; then
        pass "Export skill outputs to artifacts/exports/"
    else
        fail "Export skill missing proper output location"
    fi

    # Check for required fields
    if grep -q "metadata" "$EXPORT_SKILL" && grep -q "summary" "$EXPORT_SKILL" && grep -q "contextFiles" "$EXPORT_SKILL"; then
        pass "Export skill includes required HandoffPackage fields"
    else
        fail "Export skill missing required fields"
    fi
else
    fail "Export skill file not found"
fi

echo ""

# Test 4: /update skill validation
echo "━━━ Test: /update Skill ━━━"
echo ""

UPDATE_SKILL="$SKILLS_DIR/update/SKILL.md"
if [ -f "$UPDATE_SKILL" ]; then
    pass "Update skill file exists"

    # Check for backup creation
    if grep -q "backup\|Backup" "$UPDATE_SKILL" && grep -q "\.claude-backup" "$UPDATE_SKILL"; then
        pass "Update skill creates backup"
    else
        fail "Update skill missing backup creation"
    fi

    # Check for MIGRATION_SUMMARY.md
    if grep -q "MIGRATION_SUMMARY.md" "$UPDATE_SKILL"; then
        pass "Update skill generates MIGRATION_SUMMARY.md"
    else
        fail "Update skill missing MIGRATION_SUMMARY.md generation"
    fi

    # Check for rollback support
    if grep -q "rollback\|Rollback" "$UPDATE_SKILL"; then
        pass "Update skill supports rollback"
    else
        fail "Update skill missing rollback support"
    fi

    # Check for checksum verification
    if grep -q "checksum\|SHA\|sha256" "$UPDATE_SKILL"; then
        pass "Update skill verifies checksums"
    else
        fail "Update skill missing checksum verification"
    fi
else
    fail "Update skill file not found"
fi

echo ""

# Test 5: Schema coverage
echo "━━━ Test: Schema Coverage ━━━"
echo ""

# HandoffPackage schema should exist
if [ -f "$SCHEMAS_DIR/handoff-package.json" ]; then
    pass "HandoffPackage schema exists"

    # Check required fields in schema
    if jq -e '.required | contains(["metadata", "summary", "contextFiles", "nextSteps"])' "$SCHEMAS_DIR/handoff-package.json" > /dev/null 2>&1; then
        pass "HandoffPackage schema has correct required fields"
    else
        fail "HandoffPackage schema missing required fields"
    fi
else
    fail "HandoffPackage schema not found"
fi

echo ""

# Summary
echo "━━━ Summary ━━━"
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo ""

if [ "$FAILED" -gt 0 ]; then
    echo -e "${RED}Phase 2 tests FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Phase 2 tests PASSED${NC}"
    exit 0
fi
